class MiniTickerChannel < ApplicationCable::Channel
  def subscribed
    stream_from stream_name
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast stream_name, format_response(data)
  end

  private

  def stream_name
    "mini_ticker_#{params[:symbols]}"
  end
end
