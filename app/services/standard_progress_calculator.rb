class StandardProgressCalculator
  include Service

  # Plan:
  # - define the relevant standards
  # - fetch the count of AITStandards for each standard
  # - fetch the count of each standard for each user, by level, perhaps by game as well
  #
  # nb: if aitstandard criteria changes over time, this will become out of sync,
  # as it just compares raw counts; not counts of specific criteria. but that shouldn't
  # matter because if the user has received the award, it shows that instead of percentage.

  # Units#game: DH, RS, Arma 3, RS2, Squad
  # Awards#code: dh, rs, a3, rs2, sq

  STANDARDS = {
    eib: {notapplicable: "eib"},
    slt: {notapplicable: "anpdr"},
    rifle: {marksman: "m:rifle:{game}", sharpshooter: "s:rifle:{game}", expert: "e:rifle:{game}"},
    combat_engineer: {marksman: "m:zook:{game}", sharpshooter: "s:zook:{game}", expert: "e:zook:{game}"},
    armor: {marksman: "m:armor:{game}", sharpshooter: "s:armor:{game}", expert: "e:armor:{game}"},
    automatic_rifle: {marksman: "m:bar:{game}", sharpshooter: "s:bar:{game}", expert: "e:bar:{game}"},
    sniper: {marksman: "m:sniper:{game}", sharpshooter: "s:sniper:{game}", expert: "e:sniper:{game}"},
    grenadier: {marksman: "m:grenadier:{game}", sharpshooter: "s:grenadier:{game}", expert: "e:grenadier:{game}"},
    submachine_gun: {marksman: "m:smg:{game}", sharpshooter: "s:smg:{game}", expert: "e:smg:{game}"},
    pilot: {marksman: "m:pilot:{game}", sharpshooter: "s:pilot:{game}", expert: "e:pilot:{game}"}
  }

  # Award codes' game suffix sometimes differs from Unit#game enum
  UNIT_GAME_TO_AWARD_CODE_GAME = {
    "arma3" => "a3",
    "squad" => "sq"
  }

  def initialize(users, game)
    @users = users
    @game = game
  end

  # TODO: Make this work for units with no game value
  # Returns each user's progress percentage toward each badge, or :award.
  # {568 => {eib: {notapplicable: 13}, 90944 => {rifle: {marksman: :award, sharpshooter: 90}}}
  def call
    relevant_game_values = ["", nil, @game] # slt and eib have game set to an empty string

    # {["eib", "notapplicable"] => 13, ["rifle", "marksman"] => 9}
    criteria_counts = AITStandard
      .where(game: relevant_game_values)
      .group(:weapon, :badge)
      .count

    # {[568, "eib", "notapplicable"] => 13, [90944, "automatic_rifle", "marksman"] => 7}
    qualification_counts = AITQualification
      .joins(:ait_standard)
      .where(user: @users, ait_standard: {game: relevant_game_values})
      .group(:member_id, :weapon, :badge)
      .count
      .transform_keys do |member_id, raw_weapon, raw_badge|
        # Use the enums from AITStandard so we're comparing like-for-like
        [member_id, AITStandard.weapons.key(raw_weapon), AITStandard.badges.key(raw_badge)]
      end

    relevant_award_codes = STANDARDS.values.flat_map(&:values).map(&method(:interpolate_game))

    awards_by_user = UserAward
      .since_latest_non_honorable_discharge
      .joins(:award)
      .includes(:award)
      .where(user: @users)
      .where(awards: {code: relevant_award_codes})
      .group_by(&:member_id)

    @users.each_with_object({}) do |user, result|
      result[user.id] = {}

      STANDARDS.each do |standard, levels|
        result[user.id][standard] = {}

        levels.each do |level, award_code|
          # Check if the user has the award
          if awards_by_user[user.id]&.any? { |user_award| user_award.award.code == interpolate_game(award_code) }
            result[user.id][standard][level] = :award
          else
            # Get the count of qualifications for this user
            count = qualification_counts[[user.id, standard.to_s, level.to_s]] || 0

            # Get the total number of standards for this standard type
            total = criteria_counts[[standard.to_s, level.to_s]] || 0

            result[user.id][standard][level] = (total > 0) ? (count * 100 / total) : 0
          end
        end
      end
    end
  end

  private

  # replace "{game}" with the game string used in award codes
  # TODO: We can use the `game` column of the Award model instead
  def interpolate_game(code)
    award_code_game = UNIT_GAME_TO_AWARD_CODE_GAME[@game] || @game

    # Skip interpolation if no game is specified - return empty string for weapon codes
    return "" if award_code_game.nil? && code.include?("{game}")

    code.gsub("{game}", award_code_game.to_s)
  end
end
