require "lita-slack" if ENV.has_key?("SLACK_TOKEN")

Lita.configure do |config|
  config.robot.name = "Lita"
  config.robot.locale = :en
  config.robot.log_level = :info

  if ENV.has_key?("SLACK_TOKEN")
    config.robot.adapter = :slack
    config.adapters.slack.token = ENV["SLACK_TOKEN"]
    config.robot.admins = {
      "indirect" => "U03LDE805",
      "cyrin" => "U0ZBFPJD9"
    }.values
  else
    config.robot.adapter = :shell
  end

  config.redis[:url] = ENV["REDISTOGO_URL"] || ENV["REDIS_URL"] || "redis://localhost:6379"
  config.http.port = ENV["PORT"] || "13374"

  config.twitter.consumer_key = ENV.fetch("TWITTER_CONSUMER_KEY")
  config.twitter.consumer_secret = ENV.fetch("TWITTER_CONSUMER_SECRET")
end
