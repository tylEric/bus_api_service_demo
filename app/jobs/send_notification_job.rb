class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    # code for sending notification by email
  end
end
