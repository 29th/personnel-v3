class User < ApplicationRecord
  self.table_name = 'members'

  has_many :assignments, dependent: :delete_all, foreign_key: 'member_id'
  has_many :units, through: :assignments
  belongs_to :rank

  scope :active, -> { joins(:assignments).merge(Assignment.current).distinct }

  nilify_blanks
  validates_presence_of :last_name, :first_name, :rank

  def full_name
    [rank.name, first_name, last_name]
      .reject{ |s| s.nil? or s.empty? }
      .join(' ')
  end

  def short_name
    [rank.abbr, last_name]
      .reject{ |s| s.nil? or s.empty? }
      .join(' ')
  end

  def display_name
    short_name
  end

  def self.create_with_auth(auth)
    create! do |user|
      user.steam_id = auth['uid']
    end
  end

  def has_permission?(permission)
    permissions.pluck('abilities.abbr').include?(permission)
  end

  def has_permission_on_unit?(permission, unit)
    permissions_on_unit(unit).pluck('abbr').include?(permission)
  end

  def has_permission_on_user?(permission, user)
    permissions_on_user(user).pluck('abbr').include?(permission)
  end

  private
    def permissions
      @permissions ||= assignments
        .current
        .joins(:position, unit: {permissions: :ability})
        .where('unit_permissions.access_level <= positions.access_level')
    end

    def permissions_on_unit(unit)
      query = <<~EOF
        with recursive unit_tree (id, name, parent_id) as (
          select id, name, trim(trailing '/' from substring_index(path, '/', -2)) as parent_id
            from units
            where id = ?
          union all
          select parent.id, parent.name, trim(trailing '/' from substring_index(parent.path, '/', -2)) as parent_id
            from unit_tree as child
            join units as parent
              on child.parent_id = parent.id
        ),
        intersecting_assignments (unit_id, name, access_level) as (
          select unit_tree.id as unit_id, unit_tree.name, positions.access_level
          from unit_tree
          inner join assignments on (
            assignments.member_id = ?
            and assignments.unit_id = unit_tree.id
            and (
              assignments.start_date <= current_date
              and (assignments.end_date > current_date or assignments.end_date is null)
            )
          )
          inner join positions on (positions.id = assignments.position_id)
        )
        
        select distinct abilities.abbr
        from intersecting_assignments
        inner join unit_permissions on (
          unit_permissions.unit_id = intersecting_assignments.unit_id
          and unit_permissions.access_level <= intersecting_assignments.access_level
        )
        inner join abilities on (abilities.id = unit_permissions.ability_id) 
      EOF

      # TODO: Do we want to memoize this somehow?
      # TODO: this could be self.find_by_sql()
      Ability.find_by_sql([query, unit, id])
    end

    def permissions_on_user(user)
      query = <<~EOF
        with recursive subject_units (id, name, parent_id) as (
          select units.id, units.name, trim(trailing '/' from substring_index(path, '/', -2)) as parent_id
          from units
          inner join assignments on (
            assignments.member_id = ?
            and assignments.unit_id = units.id
            and (
              assignments.start_date <= current_date
              and (assignments.end_date > current_date or assignments.end_date is null)
            )
          )
        ),
        unit_tree (id, name, parent_id) as (
          select subject_units.id, subject_units.name, subject_units.parent_id
            from subject_units
          union all
          select parent.id, parent.name, trim(trailing '/' from substring_index(parent.path, '/', -2)) as parent_id
            from unit_tree as child
            join units as parent
              on child.parent_id = parent.id
        ),
        intersecting_assignments (unit_id, name, access_level) as (
          select unit_tree.id as unit_id, unit_tree.name, positions.access_level
          from unit_tree
          inner join assignments on (
            assignments.member_id = ?
            and assignments.unit_id = unit_tree.id
            and (
              assignments.start_date <= current_date
              and (assignments.end_date > current_date or assignments.end_date is null)
            )
          )
          inner join positions on (positions.id = assignments.position_id)
        )
        
        select distinct abilities.abbr
        from intersecting_assignments
        inner join unit_permissions on (
          unit_permissions.unit_id = intersecting_assignments.unit_id
          and unit_permissions.access_level <= intersecting_assignments.access_level
        )
        inner join abilities on (abilities.id = unit_permissions.ability_id) 
      EOF

      Ability.find_by_sql([query, user, id])
    end
end
