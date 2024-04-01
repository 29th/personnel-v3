# frozen_string_literal: true

class SetRegtHqPathToNonNull < ActiveRecord::Migration[7.1]
  def up
    Unit.find_by_abbr("Regt. HQ").update!(path: "/")
  end

  def down
    Unit.find_by_abbr("Regt. HQ").update!(path: nil)
  end
end
