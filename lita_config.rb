require "lita-slack" if ENV.has_key?("SLACK_TOKEN")
require "lita-tweet" if ENV.has_key?("TWITTER_CONSUMER_KEY")
require_relative "lib/lita/handlers/time_card" if ENV.has_key?("TIME_CARD_PASSWORD")

Lita.configure do |config|
  config.robot.name = "Lita"
  config.robot.locale = :en
  config.robot.log_level = :info

  if ENV.has_key?("SLACK_TOKEN") and not ENV.has_key?("LITA_SHELL")
    config.robot.adapter = :slack
    config.robot.admins = {
      "indirect" => "U03LDE805",
      "cyrin" => "U0ZBFPJD9"
    }.values
    config.adapters.slack.token = ENV.fetch("SLACK_TOKEN")
  else
    warn "SLACK_TOKEN is not set, running with shell interface"
    config.robot.adapter = :shell
    config.robot.admins = {"shell user" => "1"}.values
    config.adapters.shell.private_chat = true
  end

  config.redis[:url] = ENV["REDISTOGO_URL"] || ENV["REDIS_URL"] || "redis://localhost:6379"
  config.http.port = ENV.fetch("PORT", "13374")

  if ENV.has_key?("TWITTER_CONSUMER_KEY")
    config.handlers.tweet.http_url = ENV["SERVER_URL"]
    config.handlers.tweet.consumer_key = ENV.fetch("TWITTER_CONSUMER_KEY")
    config.handlers.tweet.consumer_secret = ENV.fetch("TWITTER_CONSUMER_SECRET")
  end

  if time_card_password = ENV["TIME_CARD_PASSWORD"]
    config.handlers.time_card.token = time_card_password
  end
end
