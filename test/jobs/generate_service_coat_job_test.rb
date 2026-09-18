require "test_helper"

class GenerateServiceCoatJobTest < ActiveSupport::TestCase
  BASE_URL = Settings.service_coat_generator.base_url.internal
  FAKE_PNG = "\x89PNG fake image data".b

  test "sends user details to the generator and attaches the returned image" do
    unit = create(:unit, abbr: "Able Co. HQ")
    user = create(:user, last_name: "Hopper", rank_abbr: "Cpl.")
    create(:assignment, user: user, unit: unit)
    create(:user_award, user: user, award: create(:award, code: "aocc"))
    create(:finance_record, user: user, amount_received: 25)

    generator_request = stub_request(:post, "#{BASE_URL}/")
      .with { |request|
        body = JSON.parse(request.body)
        body["last_name"] == "Hopper" &&
          body["rank_abbr"] == "Cpl." &&
          body["unit_key"] == "Able" &&
          body["awards_abbr"] == ["aocc"] &&
          body["balance"].to_d == 25
      }
      .to_return(status: 200, body: FAKE_PNG,
        headers: {"Content-Type" => "image/png"})

    GenerateServiceCoatJob.perform_now(user)

    assert_requested generator_request
    user.reload
    assert user.service_coat.present?, "service coat should be attached"
    assert_equal FAKE_PNG, user.service_coat.read
  end

  %i[general dishonorable].each do |type|
    test "only sends awards since the latest #{type} discharge" do
      user = create(:user)
      create(:discharge, user: user, type: type, date: 3.years.ago)
      create(:discharge, user: user, type: type, date: 1.year.ago)
      create(:discharge, user: user, type: :honorable, date: 1.month.ago)
      create(:user_award, user: user, date: 2.years.ago,
        award: create(:award, code: "eib"))
      award = create(:award, code: "aocc")
      create(:user_award, user: user, award: award, date: 1.year.ago)
      create(:user_award, user: user, award: award, date: 6.months.ago)

      generator_request = stub_request(:post, "#{BASE_URL}/")
        .with { |request| JSON.parse(request.body)["awards_abbr"] == ["aocc", "aocc"] }
        .to_return(status: 200, body: FAKE_PNG,
          headers: {"Content-Type" => "image/png"})

      GenerateServiceCoatJob.perform_now(user)

      assert_requested generator_request
      assert_equal 3, user.user_awards.count, "historical awardings should be retained"
    end
  end

  test "keeps awards from before an honorable discharge" do
    user = create(:user)
    create(:discharge, user: user, type: :honorable, date: 1.year.ago)
    create(:user_award, user: user, date: 2.years.ago,
      award: create(:award, code: "eib"))

    generator_request = stub_request(:post, "#{BASE_URL}/")
      .with { |request| JSON.parse(request.body)["awards_abbr"] == ["eib"] }
      .to_return(status: 200, body: FAKE_PNG,
        headers: {"Content-Type" => "image/png"})

    GenerateServiceCoatJob.perform_now(user)

    assert_requested generator_request
  end

  test "uses the most recent past unit when user has no active assignment" do
    unit = create(:unit, abbr: "Baker Co. HQ")
    user = create(:user)
    create(:assignment, user: user, unit: unit,
      start_date: 1.year.ago, end_date: 1.month.ago)

    generator_request = stub_request(:post, "#{BASE_URL}/")
      .with { |request| JSON.parse(request.body)["unit_key"] == "Baker" }
      .to_return(status: 200, body: FAKE_PNG,
        headers: {"Content-Type" => "image/png"})

    GenerateServiceCoatJob.perform_now(user)

    assert_requested generator_request
  end

  test "sends bearer token when an api key is configured" do
    user = create(:user)
    create(:assignment, user: user)

    generator_request = stub_request(:post, "#{BASE_URL}/")
      .with(headers: {"Authorization" => "Bearer sekret"})
      .to_return(status: 200, body: FAKE_PNG,
        headers: {"Content-Type" => "image/png"})

    original_api_key = Settings.service_coat_generator.api_key
    Settings.service_coat_generator.api_key = "sekret"
    begin
      GenerateServiceCoatJob.perform_now(user)
    ensure
      Settings.service_coat_generator.api_key = original_api_key
    end

    assert_requested generator_request
  end

  test "raises and leaves user untouched when the generator responds with an error" do
    user = create(:user)
    create(:assignment, user: user)

    stub_request(:post, "#{BASE_URL}/").to_return(status: 500)

    assert_raises GenerateServiceCoatJob::ServiceCoatGenerationError do
      GenerateServiceCoatJob.perform_now(user)
    end

    user.reload
    assert_nil user.service_coat
  end
end
