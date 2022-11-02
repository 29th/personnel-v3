class KeyedAITStandard
  Weapon = Struct.new(:name, :count, :badges)
  Badge = Struct.new(:name, :count, :standards)

  attr_reader :name, :count, :weapons

  def initialize(name, count = 0, weapons = {})
    @name = name
    @count = count
    @weapons = weapons
  end

  def append(standard, qualified)
    @weapons[standard.weapon] ||= Weapon.new(standard.weapon, 0, {})
    @weapons[standard.weapon].badges[standard.badge] ||= Badge.new(standard.badge, 0, [])
    @weapons[standard.weapon].badges[standard.badge].standards.append(standard)

    increment_counts(standard) if qualified
  end

  private

  def increment_counts(standard)
    @count += 1
    @weapons[standard.weapon].count += 1
    @weapons[standard.weapon].badges[standard.badge].count += 1
  end
end
