require 'date'

module Lita
  module Handlers
    class TimeCard < Lita::Handler
      namespace :time_card
      config :token

      STRING_TO_MINUTES = {
        /(\d+)m?/i => ->(minutes) { minutes.to_i },
        /(\d+):(\d+)/i => ->(hours, minutes) { hours.to_i * 60 + minutes.to_i },
        /(\d+(?:\.\d+)?)h/i => ->(hours) { hours.to_f * 60.0 },
      }

      route %r{^time_card (?<time>#{Regexp.union STRING_TO_MINUTES.keys})(?: (?<date>\d{4}-\d{2}-\d{2}))? (?<message>.+)}m,
            :log_time,
            command: true,
            help: { "time_card MINUTES [YYYY-MM-DD] MESSAGE" => "Add a time card entry." }

      def log_time(response)
        user = response.message.user
        minutes, date, message = response.match_data["time"], response.match_data["date"], response.match_data["message"]
        minutes = parse_time(minutes)
        user_time_zone = user.metadata["tz_offset"].to_i
        date ||= Time.now.getlocal(user_time_zone)
        log.debug "[time_card] #{user.name} #{date} (#{minutes} minutes): #{message}"

        post = { worker: user.name, date: date.to_s, minutes: minutes.to_i, message: message }
        r = authenticated_connection.post("/entries", post.to_json)

        log.debug "[time_card] response = #{r.inspect}"
        hours, minutes = minutes.divmod(60)
        text = "[time_card] logged "
        text << "#{hours.to_i}h " unless hours.zero?
        text << "#{minutes.to_i}m " unless minutes.zero?
        text << "on #{date.to_date.iso8601}:\n#{message}"
        response.reply(text)
      end

      def parse_time(string)
        STRING_TO_MINUTES.lazy.map do |pattern, converter|
          match_data = /\A#{pattern}\z/.match(string)
          match_data && converter[*match_data.captures]
        end.find {|minutes| !minutes.nil? }
      end

      route %r{^time_card raw (\w+) (\S+)(?:\s(.+))?}m,
        :raw,
        command: true,
        help: { "time_card raw METHOD PATH [JSON_BODY]" => "Send a raw, authenticated request to the time card API." }

      def raw(response)
        _, method, path, json = *response.match_data
        log.debug "[time_card] #{response.message.user.name} #{method} #{path} #{json}"

        r = authenticated_connection.run_request(method.downcase.to_sym, path, json, nil)

        log.debug "[time_card] response = #{r.inspect}"
        response.reply("[time_card]\n```\n#{r.body}\n```")
      end

      route %r{^time_card biweekly(?: (\d{4}-\d{2}-\d{2}))?},
        :biweekly_report,
        command: true,
        help: { "time_card biweekly [DATE]" => "Privately print the biweekly report." }

      def biweekly_report(response)
        _, date = *response.match_data
        date ||= Date.today
        log.debug "[time_card] biweekly report for #{date}"

        r = authenticated_connection.get("/report/biweekly/#{date}")
        log.debug "[time_card] response = #{r.inspect}"

        response.reply("[time_card] biweekly report for #{date}")
        reply_with_tables(response, r.body)
      end

      route %r{^time_card monthly(?: (\d{4}-\d{2}))?},
        :monthly_report,
        command: true,
        help: { "time_card monthly [DATE]" => "Privately print the monthly report." }

      def monthly_report(response)
        _, date = *response.match_data
        date ||= Date.today.strftime("%Y-%m")
        log.debug "[time_card] monthly report for #{date}"

        r = authenticated_connection.get("/report/monthly/#{date}")
        log.debug "[time_card] response = #{r.inspect}"

        response.reply("[time_card] monthly report for #{date}")
        reply_with_tables(response, r.body)
      end

      private

      def authenticated_connection
        Faraday::Connection
          .new("https://ruby-together-time-card.herokuapp.com").tap do |conn|
            conn.basic_auth("admin", config.token)
          end
      end

      def reply_with_tables(response, body)
        tables = body.gsub("+\n\n+", "+TABLE_DELIMITER+").split("TABLE_DELIMITER")
        tables.each do |table|
          response.reply("```\n#{table.strip}\n```")
        end
      end

    end

    Lita.register_handler(TimeCard)
  end
end
