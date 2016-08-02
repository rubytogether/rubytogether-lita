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

    config.redis[:url] = ENV["REDISTOGO_URL"]
    config.http.port = ENV.fetch("PORT", 13374)
  else
    config.robot.adapter = :shell
  end
end
