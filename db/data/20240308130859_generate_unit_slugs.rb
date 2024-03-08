# frozen_string_literal: true

class GenerateUnitSlugs < ActiveRecord::Migration[7.1]
  def up
    Unit.find_each(&:save)
  end

  def down
    Unit.update_all(slug: nil)
  end
end
