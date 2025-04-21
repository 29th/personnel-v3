class MissingAwardCalculator
  include Service

  def initialize(user)
    @user = user
  end

  def call
    missing_service_duration_awards
  end

  def missing_service_duration_awards
    service_duration = @user.service_duration
    since_discharge = @user.latest_non_honorable_discharge.present? ? @user.latest_non_honorable_discharge.date.. : nil

    # Calculate how many awards the user should have based on service duration
    months_of_service = (service_duration.to_i / 1.month).floor
    years_of_service = (service_duration.to_i / 1.year).floor

    # For every 6 months of service, a user should be awarded an Army of Occupation Medal (aocc)
    expected_aocc_count = (months_of_service / 6).floor

    # For every 2 years of service, a user should be awarded a World War I Victory Medal (ww1v)
    expected_ww1v_count = (years_of_service / 2).floor

    # Count how many of each award the user already has
    # Using preloaded user_awards and filtering in memory to avoid N+1 queries
    actual_aocc_count = @user.user_awards.by_date(since_discharge).count { |ua| ua.award.code == "aocc" }
    actual_ww1v_count = @user.user_awards.by_date(since_discharge).count { |ua| ua.award.code == "ww1v" }

    # Calculate missing awards
    missing_aocc = [expected_aocc_count - actual_aocc_count, 0].max
    missing_ww1v = [expected_ww1v_count - actual_ww1v_count, 0].max

    {aocc: missing_aocc, ww1v: missing_ww1v}
  end
end
