# frozen_string_literal: true

require 'oauth2'

SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/ping' do |command|
    command.logger.info 'Received a ping, responding with pong..'
    { text: 'pong' }
  end
end
