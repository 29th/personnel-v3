require "test_helper"

class CreateEnlistmentForumTopicJobTest < ActiveJob::TestCase
  test "updates the enlistment with the topic id" do
    enlistment = create(:enlistment)
    User.any_instance.expects(:create_forum_topic).returns({"topic_id" => 123})

    perform_enqueued_jobs do
      CreateEnlistmentForumTopicJob.perform_later(enlistment)
    end

    assert 123, enlistment.reload.topic_id
  end

  test "does not create a topic if topic_id already set" do
    enlistment = create(:enlistment, topic_id: 456)

    User.any_instance.expects(:create_forum_topic).never

    perform_enqueued_jobs do
      CreateEnlistmentForumTopicJob.perform_later(enlistment)
    end
  end
end
