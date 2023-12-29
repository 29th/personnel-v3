# frozen_string_literal: true

class MoveEnlistmentPreviousUnitsToOwnTable < ActiveRecord::Migration[7.1]
  def up
    Enlistment.where("previous_units IS NOT NULL AND previous_units <> ''").find_each do |enlistment|
      raw_json = enlistment.attributes["previous_units"]
      items = JSON.parse(raw_json) # array of objects
      enlistment.previous_units.build(items)
      enlistment.save(validate: false)
    end
  end

  def down
    Enlistment.where("previous_units IS NOT NULL AND previous_units <> ''").find_each do |enlistment|
      enlistment.previous_units.clear
    end
  end
end
