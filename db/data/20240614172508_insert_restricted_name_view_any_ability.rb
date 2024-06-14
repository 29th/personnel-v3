# frozen_string_literal: true

class InsertRestrictedNameViewAnyAbility < ActiveRecord::Migration[7.1]
  def up
    Ability.create!(name: "View Any Restricted Name", abbr: "restricted_name_view_any")
  end

  def down
    Ability.find_by_abbr("restricted_name_view_any").destroy!
  end
end
