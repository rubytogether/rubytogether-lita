Lita.configure do |config|
  config.robot.name = "Lita"
  config.robot.locale = :en
  config.robot.log_level = :info

  case ENV["RACK_ENV"]
  when "production"
    config.robot.adapter = :slack
    config.adapters.slack.token = "xoxb-65291979888-k8tUea3KU83uSojSiVDtV62H"
    config.robot.admins = {"indirect" => "U03LDE805", "cyrin" => "U0ZBFPJD9"}.values

    config.redis[:url] = ENV["REDISTOGO_URL"]
    config.http.port = ENV["PORT"]
  else
    config.robot.adapter = :shell
  end
end
