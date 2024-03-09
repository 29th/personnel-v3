class AttendanceStats
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :last_30_days, :float
  attribute :last_60_days, :float
  attribute :last_90_days, :float
  attribute :total, :float

  PERCENT_SINCE = <<~SQL.squish
    IFNULL(
      SUM(starts_at >= '%{date}' AND attended = true)
      / SUM(starts_at >= '%{date}')
      * 100
    , 0) AS %{name}
  SQL

  PERCENT_TOTAL = <<~SQL.squish
    IFNULL(
      SUM(attended = true)
      / COUNT(*)
      * 100
    , 0) AS total
  SQL

  def self.for_user(user)
    aggregations = [
      percent_attended(30),
      percent_attended(60),
      percent_attended(90),
      PERCENT_TOTAL
    ]

    query = AttendanceRecord
      .select(aggregations.join(", "))
      .joins(:event)
      .where(user: user, event: {mandatory: true})

    last_non_honorable_discharge = user.discharges.not_honorable.last
    if last_non_honorable_discharge.present?
      query = query.where("starts_at > ?", last_non_honorable_discharge.date)
    end

    query.first # TODO: Cast the result as AttendanceStats
  end

  def self.for_unit(unit)
    aggregations = [
      percent_attended(30),
      percent_attended(60),
      percent_attended(90),
      PERCENT_TOTAL
    ]

    AttendanceRecord
      .select(aggregations.join(", "))
      .joins(:event)
      .where(event: {unit: unit, mandatory: true})
      .first
  end

  private_class_method def self.percent_attended(days)
    from_date = (Date.today - days).iso8601
    attr_name = "last_#{days}_days"
    PERCENT_SINCE % {date: from_date, name: attr_name}
  end
end
