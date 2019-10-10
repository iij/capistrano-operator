require_relative 'rake_helpers'

namespace :operator do
  task :ping do
    on roles(:all), in: :sequence do |host|
      info "target: #{host}"
      execute 'pwd'
      hostname = capture('hostname')
      if hostname
        puts 'ping: true'
        puts "hostname: #{hostname}"
      else
        puts 'ping: false'
      end

      while true
        set :command, ask('any command(何も入力せずEnterすると抜けます)')
        break if fetch(:command) == nil
        try_to_execute(fetch(:command))
      end
    end
  end
end
