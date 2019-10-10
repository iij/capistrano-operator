module Capistrano
  module Operator
    def load_task(task)
      load File.expand_path(task, File.dirname(__FILE__))
    end
    module_function :load_task
  end
end

task_dir = 'tasks'
tasks = %W[test.rake check.rake operation.rake]

tasks.each do |task|
  Capistrano::Operator::load_task(File.join(task_dir, task))
end
