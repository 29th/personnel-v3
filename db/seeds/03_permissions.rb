# Unit permission matrix, modelled on the real configuration: each echelon
# grants a standard set of abilities per access level (member=0 is anyone in
# the unit, elevated=5 clerks, leader=10 unit leadership). A user holds an
# ability when their position's access level meets the permission's level.

PERMISSION_TEMPLATES = {
  squad: {
    member: %w[event_aar],
    leader: %w[banlog_edit_any event_aar_any manage note_view_sq
      qualification_add qualification_delete]
  },
  platoon: {
    elevated: %w[admin-awardings admin-events admin-promotions
      admin-weapon_passes assignment_add awarding_add event_aar event_add
      manage profile_edit promotion_add],
    leader: %w[assignment_delete awarding_delete banlog_edit_any event_aar_any
      note_view_pl promotion_delete qualification_add qualification_delete]
  },
  company: {
    member: %w[admin-awardings admin-events assignment_add banlog_edit_any
      discharge_add event_aar_any event_add manage],
    elevated: %w[admin-promotions admin-weapon_passes assignment_add_any
      assignment_delete awarding_add awarding_delete profile_edit
      promotion_add],
    leader: %w[admin-discharges demerit_add eloa_add_any note_view_co
      promotion_delete qualification_add qualification_delete]
  },
  battalion: {
    elevated: %w[admin-awardings admin-discharges admin-events
      admin-promotions admin-weapon_passes assignment_add assignment_add_any
      assignment_delete banlog_edit_any discharge_add event_aar_any event_add
      manage profile_edit promotion_add],
    leader: %w[awarding_add awarding_delete demerit_add eloa_add_any
      note_view_co promotion_delete qualification_add qualification_delete]
  },
  regiment: {
    member: %w[admin admin-events admin-notes admin-weapon_passes
      assignment_add_any assignment_delete_any banlog_edit_any demerit_add_any
      discharge_add_any eloa_add_any enlistment_edit_any enlistment_process_any
      event_aar_any event_add_any event_view_any finance_view_any manage
      note_view_all profile_edit profile_edit_any profile_view_any
      promotion_add_any qualification_add_any qualification_delete_any
      unit_add]
  },
  s1: {
    member: %w[admin-awardings admin-eloas admin-notes admin-weapon_passes
      banlog_edit_any demerit_add_any eloa_view_any event_add_any
      finance_view_any manage note_view_all],
    leader: %w[admin-attendance admin-discharges admin-events admin-finances
      admin-promotions assignment_add assignment_add_any assignment_delete
      assignment_delete_any discharge_add_any eloa_add_any event_aar_any
      finance_add promotion_add promotion_delete]
  },
  lighthouse: {
    member: %w[admin-weapon_passes enlistment_assign_any enlistment_edit_any
      enlistment_process_any event_aar manage note_view_lh pass_edit_any
      profile_edit restricted_name_view_any],
    elevated: %w[admin-enlistments admin-events admin-units assignment_add
      event_add unit_add],
    leader: %w[note_view_pl promotion_add]
  },
  military_police: {
    member: %w[admin-banlog banlog_edit_any manage],
    elevated: %w[note_view_mp],
    leader: %w[assignment_add demerit_add_any]
  },
  adjutant: {
    member: %w[eloa_add_any manage],
    elevated: %w[admin-eloas],
    leader: %w[assignment_add demerit_add_any note_view_pl]
  },
  finance: {
    member: %w[admin-finances admin-weapon_passes finance_add manage
      pass_edit_any],
    leader: %w[admin-awardings assignment_add note_view_pl]
  },
  staff_corps: {
    member: %w[event_aar manage],
    leader: %w[assignment_add event_add note_view_pl]
  },
  reserve: {
    leader: %w[admin-awardings admin-discharges admin-promotions
      assignment_add_any awarding_add_any awarding_delete demerit_add
      discharge_add eloa_add_any manage note_view_co profile_edit
      promotion_add promotion_delete]
  },
  admins: {
    member: %w[admin admin-attendance admin-awardings admin-banlog
      admin-discharges admin-enlistments admin-notes admin-promotions
      admin-units assignment_add_any assignment_delete_any award_add
      awarding_add_any discharge_add_any enlistment_edit_any
      enlistment_process_any event_aar_any manage profile_edit_any
      promotion_add_any promotion_delete_any qualification_add_any
      qualification_delete_any unit_add]
  }
}

def permission_template_for(unit)
  case unit.abbr
  when "Regt. HQ" then :regiment
  when /Bn\. HQ$/ then :battalion
  when /Co\. HQ$/ then :company
  when /P\d HQ$/ then :platoon
  when "S-1" then :s1
  when "LH" then :lighthouse
  when "MP" then :military_police
  when "Adj" then :adjutant
  when "Fin" then :finance
  when "Rsrv S1" then :reserve
  when "Admins" then :admins
  else
    if unit.combat? && unit.name.include?("Squad")
      :squad
    elsif unit.staff?
      :staff_corps
    end
  end
end

ability_ids = Ability.pluck(:abbr, :id).to_h
access_levels = {member: 0, elevated: 5, leader: 10}
permission_rows = []

Unit.active.find_each do |unit|
  template = PERMISSION_TEMPLATES[permission_template_for(unit)]
  next unless template

  template.each do |level, abbrs|
    abbrs.each do |abbr|
      permission_rows << {unit_id: unit.id,
                          access_level: access_levels.fetch(level),
                          ability_id: ability_ids.fetch(abbr)}
    end
  end
end
Permission.insert_all(permission_rows)

# Legacy v2 class-wide permissions (no v3 model, but kept populated for parity)
class_permission = Class.new(ApplicationRecord) { self.table_name = "class_permissions" }
class_permission.insert_all(
  [[nil, "profile_view_any"]]
    .concat(%w[event_view_any unit_stats_any finance_view_any eloa_view_any
      demerit_view_any note_view_any banlog_view_any qualification_view_any]
      .flat_map { |abbr| [["Combat", abbr], ["Staff", abbr]] })
    .map { |klass, abbr| {"class" => klass, "ability_id" => ability_ids.fetch(abbr)} }
)

puts "   unit_permissions: #{Permission.count}"
