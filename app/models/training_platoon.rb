class TrainingPlatoon < Unit
  default_scope { training_platoons }

  has_many :_accepted_enlistments, -> { accepted }, class_name: "Enlistment", foreign_key: "unit_id"
  has_many :cadets, through: :_accepted_enlistments, class_name: "Cadet", source: :user
end
