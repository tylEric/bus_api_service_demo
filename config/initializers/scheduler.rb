require 'rufus-scheduler'

s = Rufus::Scheduler.singleton

s.every '30s' do
  # pull routes info
  # then parse data and get all stops with 0 EstimateTime
  # store the result in stops
  stops = []

  # also generate keys for subscribed next three stops from pulling response
  keys_set_for_subscribed_next_three_stops = Set.new([])

  stops.each do |stop|
    if $stops_and_notify_list_mapping_list.key? stop
      keys = $stops_and_notify_list_mapping_list[stop]
      keys.each do |key|
        # prevent notify user subscribed a stop
        # but triggered by different bus / destination
        next unless keys_set_for_subscribed_next_three_stops.include? key

        # query users in single DB I/O
        users_subscribed_next_three_stop = User.where(id: $notify_list[key])
        unless users_subscribed_next_three_stop.empty?
          users_subscribed_next_three_stop.each do |user|
            SendNotificationJob.perform_later(user)
          end
        end
      end
    end
  end
end
