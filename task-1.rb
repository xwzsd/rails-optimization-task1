# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'ruby-progressbar'
require 'readline'

class User
  attr_reader :attributes
  attr_accessor :sessions, :browsers, :dates, :session_times

  def initialize(attributes)
    @attributes = attributes
    @sessions = []
    @browsers = []
    @dates = []
    @session_times = []
  end
end

def work(disable_gc: true)
  GC.disable if disable_gc

  file_lines = File.read('data.txt').split("\n")

  @current_users = []
  @current_sessions = []
  uniqueBrowsers = []
  report = {}
  report[:usersStats] = {}

  file_lines.each do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      # Инициализация пользователя
      @current_users << parse_user(cols)
    else
      # Статистика по пользователям
      session = parse_session(cols)
      @current_users.last.sessions << session
      @current_users.last.browsers << session[:browser].upcase
      @current_users.last.dates << session[:date]
      @current_users.last.session_times << session[:time].to_i
      @current_sessions << session
      # Подсчёт количества уникальных браузеров
      uniqueBrowsers << session[:browser].upcase
    end
  end

  @current_users.each do |user|
    collect_stats_from_users(user, report)
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

  report[:totalUsers] = @current_users.count

  report[:uniqueBrowsersCount] = uniqueBrowsers.uniq.count
  report[:totalSessions] = @current_sessions.count
  report[:allBrowsers] = uniqueBrowsers.sort.uniq.join(',')

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

def collect_stats_from_users(user, report)
  user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"

  report[:usersStats][user_key] ||= {
    # Собираем количество сессий по пользователям
    sessionsCount:  user.sessions.size,
    # Собираем количество времени по пользователям
    totalTime: "#{user.session_times.sum} min.",
    # Выбираем самую длинную сессию пользователя
    longestSession: "#{user.session_times.max} min.",
    # Браузеры пользователя через запятую
    browsers: user.browsers.sort.join(', '),
    # Хоть раз использовал IE?
    usedIE: user.sessions.any? { |s| s[:browser].upcase =~ /INTERNET EXPLORER/ },
    # Всегда использовал только Chrome?
    alwaysUsedChrome: user.sessions.all? { |s| s[:browser].upcase =~ /CHROME/ },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    dates: user.dates.sort.reverse
  }
end
