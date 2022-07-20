FactoryBot.define do
  sequence(:random_id, (1..100000).to_a.shuffle.to_enum)

  factory :ability do
    abbr { "admin" }
    name { abbr }
  end

  factory :ait_qualification do
    user
    ait_standard
    author factory: :user
    date { 1.day.ago }
  end

  factory :ait_standard do
    weapon { :rifle }
    game { :squad }
    badge { :marksman }
    description { Faker::Lorem.sentence }
  end

  factory :assignment do
    unit
    user
    position
    start_date { Date.yesterday }

    trait :elevated do
      position { build(:position, access_level: :elevated) }
    end

    trait :leader do
      position { build(:position, access_level: :leader) }
    end
  end

  factory :attendance_record do
    event
    user
    excused { false }
  end

  factory :award do
    code { "shiny" }
    title { "Shiny medal" }
    description { "Given to all the good soldiers" }
    game { :notapplicable }
    image { Faker::Internet.url }
    thumbnail { Faker::Internet.url }
    bar { Faker::Internet.url }
  end

  factory :ban_log do
    date { 1.day.ago }
    roid { Faker::Number.number(digits: 17).to_s }
    admin factory: :user
    poster factory: :user
  end

  factory :country do
    abbr { "US" }
    name { "United States" }
  end

  factory :demerit do
    user
    author factory: :user
    date { 1.day.ago }
    reason { Faker::Lorem.sentence }
    forum_id { :discourse }
    topic_id { 123 }
  end

  factory :discharge do
    user
    date { 1.day.ago }
    type { :general }
    reason { Faker::Lorem.sentence }
    forum_id { :discourse }
    topic_id { 123 }
  end

  factory :enlistment do
    user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    age { rand(13..85) }
    date { Date.current }
    country
    timezone { :est }
    steam_id { Faker::Number.number(digits: 17).to_s }
    experience { "none" }
    comments { "" }
    recruiter { "" }
    ingame_name { "" }
  end

  factory :extended_loa do
    user
    start_date { 1.day.from_now }
    end_date { 1.week.from_now }
    reason { Faker::Lorem.sentence }
  end

  factory :note do
    user
    author factory: :user
    access { :members_only }
    subject { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
  end

  factory :pass do
    user
    author factory: :user
    start_date { 1.day.from_now }
    end_date { 2.days.from_now }
    type { :recruitment }
    reason { "Recruited someone" }
  end

  factory :permission do
    unit
    access_level { :member }

    transient do
      abbr { "ability" }
    end

    ability do
      association(:ability, abbr: abbr) if abbr.present?
    end

    trait :elevated do
      access_level { :elevated }
    end

    trait :leader do
      access_level { :leader }
    end
  end

  factory :position do
    name { "Rifleman" }
    access_level { :member }
  end

  factory :promotion do
    user
    date { 1.day.ago }
    forum_id { :discourse }
    topic_id { 123 }

    transient do
      rank_abbr { nil }
    end

    new_rank do
      rank_attrs = {}
      rank_attrs[:abbr] = rank_abbr if rank_abbr.present?
      association(:rank, **rank_attrs)
    end
  end

  factory :rank do
    abbr { "Pvt." }
    name { abbr || "Private" }
    order { 0 }
  end

  factory :restricted_name do
    user
    name { user.last_name }
  end

  factory :server do
    name { "Platoon server" }
    abbr { "Plt" }
    address { "0.0.0.0" }
    game { :rs2 }
    port { 1234 }
    active { true }
  end

  factory :special_forum_role do
    special_attribute { :everyone }
    forum_id { :discourse }
    role_id { FactoryBot.generate(:random_id) }
  end

  factory :unit do
    abbr { "Bn. HQ" }
    name { abbr || "Battalion HQ" }
    classification { "Combat" }

    transient {
      parent { nil }
    }
    ancestry {
      parent ? [parent.ancestry, parent.id].compact.join("/") : nil
    }
  end

  factory :unit_forum_role do
    unit
    access_level { :member }
    forum_id { :discourse }
    role_id { FactoryBot.generate(:random_id) }

    trait :elevated do
      access_level { :elevated }
    end

    trait :leader do
      access_level { :leader }
    end
  end

  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    steam_id { Faker::Number.number(digits: 17).to_s }
    forum_member_id { FactoryBot.generate(:random_id) }

    transient do
      rank_abbr { nil }
    end

    rank do
      rank_attrs = {}
      rank_attrs[:abbr] = rank_abbr if rank_abbr.present?
      association(:rank, **rank_attrs)
    end
  end

  factory :user_award do
    user
    award
    date { 1.day.ago }
    forum_id { :vanilla }
    topic_id { 123 }
  end

  factory :event do
    unit
    type { "Squad Drills" }
    mandatory { false }
    datetime { 1.hour.from_now }
    server
  end
end
