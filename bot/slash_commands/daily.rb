# frozen_string_literal: true

SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/daily' do |command|
    p command
    channel_id = command[:channel_id]
    DailyService.call channel_name: nil, channel_id: channel_id
    nil
  end
end
