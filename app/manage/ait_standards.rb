ActiveAdmin.register AITStandard do
  permit_params :weapon, :game, :badge, :description, :details
  menu parent: "AIT"

  filter :weapon, as: :select, collection: -> { AITStandard.weapons.map(&:reverse) }
  filter :game, as: :select, collection: -> { AITStandard.games.map(&:reverse) }
  filter :badge, as: :select, collection: -> { AITStandard.badges.map(&:reverse) }

  index do
    selectable_column
    column :weapon
    column :game
    column :badge
    column :description
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :weapon, as: :select, collection: AITStandard.weapons.map(&:reverse)
      f.input :game, as: :select, collection: AITStandard.games.map(&:reverse)
      f.input :badge, as: :select, collection: AITStandard.badges.map(&:reverse)
      f.input :description, as: :string
      f.input :details
    end
    f.actions
  end
end
