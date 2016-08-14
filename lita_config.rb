require "lita-slack" if ENV.has_key?("SLACK_TOKEN")

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
  else
    warn "SLACK_TOKEN is not set, running with shell interface"
    config.robot.adapter = :shell
    config.robot.admins = {"shell user" => "1"}.values
    config.adapters.shell.private_chat = true
  end

  # The slack adapter will throw an error when its token isn't set,
  # even when `config.robot.adapter = :shell`.
  config.adapters.slack.token = ENV["SLACK_TOKEN"]

  config.redis[:url] = ENV["REDISTOGO_URL"] || ENV["REDIS_URL"] || "redis://localhost:6379"
  config.http.port = ENV.fetch("PORT", "13374")

  config.handlers.tweet.http_url = ENV["SERVER_URL"]
  config.handlers.tweet.consumer_key = ENV.fetch("TWITTER_CONSUMER_KEY")
  config.handlers.tweet.consumer_secret = ENV.fetch("TWITTER_CONSUMER_SECRET")
end
