require 'yaml'
require 'awesome_print'

namespace :operator do
  task :check do

    set :operation, ENV['operation']

    if fetch(:operation).nil?
      puts 'please set operation.(e.g. bundle exec cap staging check:yaml operation=sample)'
      exit 1
    end

    on roles(:all) do |host|
      yaml = YAML.load_file("./operations/#{fetch(:operation)}.yml")
      ap yaml
    end
  end
end
