# frozen_string_literal: true

class AddManagePermissionToApplicableUnits < ActiveRecord::Migration[7.1]
  def up
    manage_ability = Ability.create!(
      abbr: "manage",
      name: "Manage",
      description: "Access the /manage/ section of the site"
    )

    execute <<~SQL
      insert into unit_permissions (unit_id, access_level, ability_id)
      select
        u.id as unit_id,
        min(up.access_level) as access_level,
        #{manage_ability.id} as ability_id
      from unit_permissions as up
      left join units as u
        on u.id = up.unit_id
      left join abilities as a
        on a.id = up.ability_id
      where u.active = true
        and a.abbr not like 'event_aar%'
      group by u.id
      
    SQL
  end

  def down
    manage_ability = Ability.find_by_abbr("manage")
    manage_ability.permissions.destroy_all
    manage_ability.destroy
  end
end
