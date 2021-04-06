# typed: false
# frozen_string_literal: true

# ServiceClass sends Daily standup message to any channel
class DailyService < MiniService::Base
  arguments [:channel_name], { channel_id: nil }

  def perform
    post_daily_message(channel_name, channel_id)
  end

  private

  def post_daily_message(channel_name, channel_id)
    slack_client = Slack::Web::Client.new(token: ENV['SLACK_TOKEN_OAUTH'])

    channel = search_channel(slack_client, channel_name, channel_id)
    return nil if channel.nil?

    message = format_message(channel[:id], channel[:name], date_formmatted, meet_url,
                             channel_members(slack_client, channel[:id]).shuffle!)
    slack_client.chat_postMessage(message)
  end

  def search_channel(slack_client, channel_name, channel_id)
    channel = channel_by_name(slack_client, channel_name) if channel_id.nil?
    channel = slack_client.conversations_info({ channel: channel_id }).channel if channel.nil?
    channel
  end

  def meet_url
    'https://meet.google.com/ghr-xjdy-vik'
  end

  def date_formmatted
    Time.now.strftime('%B %e, %Y').capitalize
  end

  def channel_by_name(slack_client, channel_name)
    channels = slack_client.conversations_list({ types: 'public_channel,private_channel' })
    channels.channels.select { |channel| channel.name == channel_name }&.first
  end

  def user_names(slack_client)
    slack_client.users_list.members.reject { |m| m.profile.bot_id }.collect do |m|
      [m.id, m.name.split('.')[0].capitalize]
    end.to_h
  end

  def channel_members(slack_client, channel_id)
    user_names = user_names(slack_client)
    channel_members = []
    slack_client.conversations_members({ channel: channel_id }).members.each do |user_id|
      channel_members << user_names[user_id] if user_names.key?(user_id)
    end
    return channel_members
  end

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
end
