require_relative 'rake_helpers'

require 'yaml'
require 'awesome_print'

namespace :operator do
  task :apply do

    set :operation_name, ENV['operation']

    raise_error_with_usage('Please set operation.') if fetch(:operation_name).nil?
    on roles(:all), in: :sequence do |host|
      puts "target: #{host}"
      tasks = load_tasks(fetch(:operation_name), nil)
      exit 1 if @undefined_var_flag

      @TASK_SIZE = tasks.size.freeze
      @TASK_INDEX = -1
      execute_tasks(tasks, host)
    end
  end

  def execute_tasks(tasks, host)
    tasks.each do |task|
      execute_commands_task(task, host) if task['execute_commands'] || task['check_commands']
    end
  end

  def confirm_task(task)
    @TASK_INDEX += 1
    while true
      debug "task: #{task.inspect}"
      debug 'ask [y/n/s/r]'
      puts "\n以下のタスクを実行しますか？"

      puts '======================================='
      puts_progress
      ap task
      puts '======================================='

      set :task_confirm, ask('any command (y:実行 n:中断 s:スキップ r:再確認) [y/n/s/r]')

      if fetch(:task_confirm) == 'y'
        puts "y: 実行します\n"
        debug 'y is selected'
        return true
      elsif fetch(:task_confirm) == 'n'
        puts "n: 中断します\n"
        debug 'n is selected'
        exit 1
      elsif fetch(:task_confirm) == 's'
        puts "s: スキップします\n"
        debug 's is selected'
        return false
      end
    end
  end

  def execute_commands_task(task, host)
    return unless confirm_task(task)

    if task['execute_commands']
      execute_all_commands(task['execute_commands'], host)
    end
    if task['check_commands']
      execute_each_commands_with_check(task)
    end
  end

  def execute_all_commands(task, host)
    task.each do |cmd|
      puts <<-EOS
=======================================
execute: '#{cmd}'
=======================================
      EOS
      send_command(cmd, host)
    end
  end

  def execute_each_commands_with_check(task)
    task['check_commands'].each do |cmd|
      while true
        output = send_check_command(cmd)
        debug 'ask [y/n/r]'

        enable_highlight(task['highlight']) if task['highlight']
        puts <<-EOS
=======================================
check: '#{cmd}'
result:
#{output}
=======================================
        EOS
        disable_highlight if task['highlight']

        set :answer, ask('any command (y:続行 n:中断 r:再確認) [y/n/r]')
        if fetch(:answer) == 'y'
          puts 'y: 続行します'
          debug 'y is selected'
          break
        elsif fetch(:answer) == 'n'
          puts 'n: 中断します'
          debug 'n is selected'
          exit 1
        end
      end
    end
  end

  def send_command(cmd, host)
    debug "execute: #{cmd}"
    puts "host: #{host.hostname}"
    if dry_run?
      try_to_execute(cmd)
    else
      run_interactively host do
        try_to_execute(cmd)
      end
    end
  end

  def send_check_command(cmd)
    debug "check: #{cmd}"
    result = try_to_capture(cmd)
    debug "check_result: #{result}"
    result
  end


  def load_operation_yml(file_name)
    file_path = File.join('.', 'operations', file_name)
    yml_extension = %w(.yml .yaml)
    if yml_extension.include?(File.extname(file_path))
      files = [file_path]
    else
      files = yml_extension.map {|ext| "#{file_path}#{ext}"}
    end
    files.each { |file| return YAML.load_file(file).merge(file: file) if File.exist?(file) }
    raise_error_with_usage("can not find the operation file: #{files.join(' or ')}")
  end

  def puts_progress
    puts "(#{@TASK_INDEX + 1}/#{@TASK_SIZE})"
  end

  def load_tasks(operation_name, imported_vars_hash)
    yml = load_operation_yml(operation_name)
    tasks = []

    yml['vars'].merge!(imported_vars_hash) if imported_vars_hash
    tmp_tasks = yml['vars'] ? apply_vars_to_tasks(yml['tasks'], yml['vars'], yml[:file]) : yml['tasks']
    tmp_tasks.each do |task|
      if task['import']
        import_tasks = load_tasks(task['import'], task['vars'])
        tasks.concat import_tasks
      else
        tasks.push task
      end
    end

    tasks
  end

  def apply_vars_to_tasks(tasks, vars, file)
    tasks.each_with_index do |task, i|
      task.each do |cmd_types, cmds|
        tasks[i][cmd_types] = apply_vars_to_task(cmds, vars, file)
      end
    end
    tasks
  end

  def apply_vars_to_task(cmds, vars, file)
    if cmds.kind_of?(String)
      cmds = apply_vars_to_cmd(cmds, vars, file)
    end
    if cmds.kind_of?(Array)
      cmds.each_with_index do |cmd, i|
        cmds[i] = apply_vars_to_cmd(cmd, vars, file)
      end
    end
    if cmds.kind_of?(Hash)
      cmds.each do |import_var_name, import_var_val|
        cmds[import_var_name] = apply_vars_to_cmd(import_var_val, vars, file)
      end
    end
    cmds
  end

  def apply_vars_to_cmd(cmd, vars, file)
    undefined_var = []
    var_pattern = /{{([-0-9a-zA-Z_]+)}}/
    cmd.gsub!(var_pattern) do |var|
      undefined_var << var unless vars[var[var_pattern, 1]]
      vars[var[var_pattern, 1]]
    end
    if undefined_var.count > 0
      @undefined_var_flag = true
      warn_highlight { puts("#{file}: variable is undefined: #{undefined_var.join(', ')}") }
    end
    cmd
  end
end
