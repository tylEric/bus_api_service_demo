class BusesController < ApplicationController
  before_action :set_subscribe_vars, only: [:subscribe, :unsubscribe]

  def get_bus_stops_info
    # an api for specific bus number and arrival time:
    # https://tdx.transportdata.tw/api/basic/v3/Bus/EstimatedTimeOfArrival/City/Tainan/19

    # parse the response and generate stops_and_arrival_time_pairs
    stops_and_arrival_time_pairs = { stop_1: estimated_time_1, stop_2: estimated_time_2}

    render json: stops_and_arrival_time_pairs
  end

  def subscribe
    return :bad_request if @subscribe == false # unsubscribe action

    # add user to notify list
    if notify_list.key? @key
      notify_list[@key].push(@user_id)
    else
      notify_list[@key] = [@user_id]
    end

    # find the privous stop for sending notification
    bus_info = BusInfo.find(@bus_number)
    privous_stop_for_sending_notification = nil
    if bus_info.route_1[:destination] == @destination
      subscribed_stop_index = bus_info.route_1[:stop].index(@stop)
      privous_stop_for_sending_notification = bus_info.route_1[:stop][subscribed_stop_index - 3]
    else
      subscribed_stop_index = bus_info.route_2[:stop].index(@stop)
      privous_stop_for_sending_notification = bus_info.route_2[:stop][subscribed_stop_index - 3]
    end

    # add the key to privous stop
    if stops_and_notify_list_mapping_list.key? privous_stop_for_sending_notification[:id]
      stops_and_notify_list_mapping_list[privous_stop_for_sending_notification].push @key
    else
      stops_and_notify_list_mapping_list[privous_stop_for_sending_notification] = [@key]
    end

    return :created
  end

  def unsubscribe
    return :bad_request if @subscribe == true # subscribe action

    if notify_list.key? @key
      notify_list[@key].delete(@user_id)
    else
      # do nothing
    end

    return :ok
  end

  private

  def get_bus_stops_info_params
    params.permit(:bus, :destination)
  end

  def subscribe_params
    # :user_id => uuid of a user, :int
    # :bus => bus number, :string
    # :destination => destination, :string
    # :stop => stop uuid, :string
    # :subscribe => turn on / off subscription, :boolean
    params.permit(:user_id, :bus, :destination, :stop, :subscribe)
  end

  def set_subscribe_vars
    @bus_number = subscribe_params[:bus]
    @destination = subscribe_params[:destination]
    @stop = subscribe_params[:stop]
    @user_id = subscribe_params[:user_id]
    @subscribe = subscribe_params[:subscribe]
    @key = [@bus_number, @destination, @stop].join('-')
  end

  def notify_list
    # {
    #   672-大鵬新城-博仁醫院 => [user_id_1, user_id_2, ...],
    #   282-圓環-國父紀念館 => [user_id_2, user_id_5, ...]
    # }
    $notify_list
  end

  def stops_and_notify_list_mapping_list
    # 假設 stop_1 是 bus_1-destination_1-stop_4,
    #                bus_8-destination_3-stop_k 的前三站
    # {
    #   stop_1 => [
    #     bus_1-destination_1-stop_4,
    #     bus_8-destination_3-stop_k
    #   ]
    # }
    $stops_and_notify_list_mapping_list
  end
end
