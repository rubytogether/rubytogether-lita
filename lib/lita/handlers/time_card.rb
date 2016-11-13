require 'date'

module Lita
  module Handlers
    class TimeCard < Lita::Handler
      namespace :time_card
      config :token

      route %r{^time_card (\d+)(?: (\d{4}-\d{2}-\d{2}))? (.+)}m,
            :log_time,
            command: true,
            help: { "time_card MINUTES [DATE] MESSAGE" => "Add a time card entry." }

      def log_time(response)
        user = response.message.user
        minutes, date, message = *response.match_data
        user_time_zone = user.metadata["tz_offset"].to_i
        date ||= Time.now.getlocal(user_time_zone)
        log.debug "[time_card] #{user.name} #{date} (#{minutes} minutes): #{message}"

        post = { worker: user.name, date: date.to_s, minutes: minutes.to_i, message: message }
        r = Faraday::Connection
          .new("https://ruby-together-time-card.herokuapp.com")
          .basic_auth("admin", config.token)
          .post("/entries", post)

        log.debug "[time_card] response = #{r.inspect}"
        response.reply("[time_card]\n```json\n#{r.body}\n```")
      end

      route %r{^time_card raw (\w+) ([/.\w]+)(.+)?}m,
        :raw,
        command: true,
        help: { "time_card raw METHOD PATH JSON_BODY" => "Send a raw, authenticated request to the time card API." }

      def raw(response)
        method, path, json = *response.match_data
        log.debug "[time_card] #{response.message.user.name} #{method} #{path} #{json}"

        post = json && JSON.parse(json)
        r = Faraday::Connection
          .new("https://ruby-together-time-card.herokuapp.com")
          .basic_auth("admin", config.token)
          .run_request(method.downcase.to_sym, path, post, nil)

        log.debug "[time_card] response = #{r.inspect}"
        response.reply("[time_card]\n```json\n#{r.body}\n```")
      end

      route %r{^time_card biweekly(?: (\d{4}-\d{2}-\d{2}))?},
        :biweekly_report,
        command: true,
        help: { "time_card biweekly [DATE]" => "Privately print the biweekly report." }

      def biweekly_report(response)
        date, = *response.match_data
        date ||= Date.today
        log.debug "[time_card] biweekly report for #{date}"

        post = { worker: user.name, date: date.to_s, minutes: minutes.to_i, message: message }
        r = Faraday::Connection
          .new("https://ruby-together-time-card.herokuapp.com")
          .basic_auth("admin", config.token)
          .post("/report/biweekly/#{date}", post)

        log.debug "[time_card] response = #{r.inspect}"
        response.reply("[time_card] report for #{date}\n```\n#{r.body}\n```")
      end
    end

    Lita.register_handler(TimeCard)
  end
end
