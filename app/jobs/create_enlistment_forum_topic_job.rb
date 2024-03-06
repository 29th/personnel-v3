class CreateEnlistmentForumTopicJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform(enlistment)
    return if enlistment.topic_id.present?

    category = Settings.discourse.categories.enlistment_office
    embed_url = enlistment_url(enlistment, host: Settings.host)
    title = "Enlistment - #{enlistment.user.short_name}"
    body = "Read the enlistment details at: \n\n#{embed_url}"

    topic_data = enlistment.user.create_forum_topic(category, title, body,
      external_id: enlistment.id, embed_url: embed_url)

    enlistment.update(
      topic_id: topic_data["topic_id"],
      forum_id: :discourse
    )
  end
end
