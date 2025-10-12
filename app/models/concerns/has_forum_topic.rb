module HasForumTopic
  extend ActiveSupport::Concern

  included do
    enum :forum_id, {phpbb: "PHPBB",
                    smf: "SMF",
                    vanilla: "Vanilla",
                    discourse: "Discourse"}

    validates :forum_id, presence: true, if: -> { topic_id.present? }
    validates :topic_id, numericality: {only_integer: true}, allow_nil: true,
      allow_blank: true
  end
end
