# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'ruby-progressbar'
require 'readline'

class User
  attr_reader :attributes
  attr_accessor :sessions

  def initialize(attributes)
    @attributes = attributes
    @sessions = []
  end
end

def work(disable_gc: true)
  GC.disable if disable_gc

  file_lines = File.read('data.txt').split("\n")

  @current_users = []
  @current_sessions = []
  uniqueBrowsers = []

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      # Инициализация пользователя
      @current_users << parse_user(cols)
    else
      # Статистика по пользователям
      session = parse_session(cols)
      @current_users.last.sessions << session
      @current_sessions << session
      # Подсчёт количества уникальных браузеров
      uniqueBrowsers << session[:browser]
    end
  end

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report[:totalUsers] = @current_users.count

  report['uniqueBrowsersCount'] = uniqueBrowsers.uniq.count
  report['totalSessions'] = @current_sessions.count
  report['allBrowsers'] = @current_sessions.map { |s| s[:browser].upcase }.sort.uniq.join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, @current_users) do |user|
    {
      # Собираем количество сессий по пользователям
      'sessionsCount' => user.sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => user.sessions.map { |s| s[:time].to_i }.sum.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
      'longestSession' => user.sessions.map { |s| s[:time].to_i }.max.to_s + ' min.',
      # Браузеры пользователя через запятую
      'browsers' => user.sessions.map { |s| s[:browser].upcase }.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => user.sessions.any? { |s| s[:browser].upcase =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user.sessions.all? { |s| s[:browser].upcase =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map{|s| s[:date]}.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end

def parse_user(fields)
  parsed_result = {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
  User.new(parsed_result)
end

def parse_session(fields)
  parsed_result = {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end
