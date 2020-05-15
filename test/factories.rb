FactoryBot.define do
  factory :unit do
    transient do
      parent { nil }
    end

    abbr { 'Bn. HQ' }
    name { abbr || 'Battalion HQ' }
    path { parent ? "#{parent.path}#{parent.id}/" : '/' }
  end

  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    steam_id { Faker::Number.number(digits: 17).to_s }

    transient do
      rank_abbr { nil }
    end

    rank do
      rank_attrs = {}
      rank_attrs[:abbr] = rank_abbr if rank_abbr.present?
      association(:rank, **rank_attrs)
    end
  end

  factory :rank do
    abbr { 'Pvt.' }
    name { abbr || 'Private' }
    order { 0 }
  end

  factory :position do
    name { 'Rifleman' }
    access_level { :member }
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

  factory :ability do
    abbr { 'admin' }
    name { abbr }
  end

  factory :permission do
    unit
    access_level { :member }

    transient do
      abbr { nil }
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
end
