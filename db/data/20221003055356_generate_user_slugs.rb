# frozen_string_literal: true

class GenerateUserSlugs < ActiveRecord::Migration[7.0]
  def up
    # Give first dibs on slugs to active users. Anyone with a slug
    # that's already in use will get another slug like fname-lname.
    active_count = 0
    User.active.find_each do |user|
      user.save!
      active_count += 1
    end

    # Not quite a list of retired members; just members who at one
    # point were honorably discharged. It's surprisingly difficult
    # to get a list of retired members, and isn't necessary here,
    # since we just want to prioritise them over everyone else for
    # slug generation.
    retired_count = 0
    Discharge.includes(:user)
      .where(type: :honorable, user: {slug: nil})
      .find_each do |discharge|
      discharge.user.save!
      retired_count += 1
    end

    inactive_count = 0
    User.where(slug: nil).find_each do |user|
      if user.save # don't raise on failure; skip instead
        inactive_count += 1
      end
    end

    puts "Generated slugs for #{active_count} active users, #{retired_count} retired users, and #{inactive_count} inactive users."
  end

  def down
    User.update_all(slug: nil)
  end
end
