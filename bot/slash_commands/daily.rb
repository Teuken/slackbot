# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
def format_message(channel_id, channel_name, date_formmatted, meet_url, user_names)
  {
    channel: channel_id,
    "blocks": [
      {
        "type": 'header',
        "text": {
          "type": 'plain_text',
          "text": ':rotating_light:  Daily Meeting  :rotating_light:'
        }
      },
      {
        "type": 'context',
        "elements": [
          {
            "text": "*#{date_formmatted}*  |  #{channel_name} Team Announcements",
            "type": 'mrkdwn'
          }
        ]
      },
      {
        "type": 'divider'
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": 'Hola *Equipo*:wave: _Buenos Días_:robot_face:'
        }
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": '_Como les tinca este orden?_ :thinking-face-rotating:'
        }
      },
      {
        "type": 'section',
        "text": {
          "type": 'mrkdwn',
          "text": user_names.join(', ').to_s
        },
        "accessory": {
          "type": 'button',
          "text": {
            "type": 'plain_text',
            "text": 'Ir al Meet :google_meet:',
            "emoji": true
          },
          "value": 'click_me_123',
          "url": meet_url.to_s,
          "action_id": 'button-action'
        }
      }
    ]
  }
end
# rubocop:enable Metrics/MethodLength

SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/daily' do |command|
    p command
    channel_id = command[:channel_id]
    command.logger.info "Someone started a quiz in channel #{channel_id}."
    slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN_OAUTH'])
    user_names = slack_client.users_list.members.reject { |m| m.profile.bot_id }.collect do |m|
      [m.id, m.name]
    end.to_h
    channel_members = []
    slack_client.conversations_members({ channel: channel_id }).members.each do |user_id|
      channel_members << user_names[user_id] if user_names.key?(user_id)
    end
    channel = slack_client.conversations_info({ channel: channel_id })
    meet_url = 'https://meet.google.com/ghr-xjdy-vik'
    date_formatted = Time.now.strftime('%B %e, %Y').capitalize

    slack_client.chat_postMessage(format_message(channel_id, channel[:channel][:name], date_formatted, meet_url,
                                                 channel_members.shuffle!))
    nil
  end
end
