namespace :operator do
  desc 'Install Capistrano-operator, operator install'
  task :install do
    src_import_sample_files = %i[import-sample.yml]
    src_import_sample_dir = '../../../../operations'
    dst_import_dir_name = 'operations'
    src_op_sample_files = %i[rm.yml touch.yml]
    src_op_sample_dir = '../../../../operations/imports'
    dst_op_sample_dir_name = 'operations/imports'

    cap_str = 'require "capistrano/operator"'
    cap_file = 'Capfile'

    init_file(src_import_sample_dir, src_import_sample_files, dst_import_dir_name)
    init_file(src_op_sample_dir, src_op_sample_files, dst_op_sample_dir_name)

    insert_str_in_file(cap_str, cap_file)

    puts 'operator is installed.'
  end

  def init_file(src_dir, src_files, dst_dir_name)
    files_hash = generate_file_hash(src_dir, src_files)
    dst_dir = make_dir(dst_dir_name)

    src_files.each do |file|
      dst_file = File.join(dst_dir, file.to_s)
      if File.exist?(dst_file)
        warn "[skip] #{dst_file} already exists"
      else
        FileUtils.cp(files_hash[file], dst_file)
        puts "create #{dst_file}"
      end
    end
  end

  def generate_file_hash(dir, files)
    files_hash = array_to_hash(files)
    files.each { |file| files_hash[file] = File.expand_path(File.join(dir, file.to_s), __FILE__) }
    files_hash
  end

  def array_to_hash(array)
    Hash[*array.zip(Array.new(array.count) { [] }).flatten(1)]
  end

  def make_dir(dir_name)
    dir = Pathname.new(dir_name)
    mkdir_p dir
    dir
  end

  def insert_str_in_file(str, path)
    str_include = nil
    File.open(path, 'a+') do |file|
      file.each_line do |line|
        if line.start_with?(str)
          str_include = true
          break
        end
      end

      if str_include
        warn "[skip] string:#{str} already exists in #{path}"
      else
        file.write(str) unless str_include
        puts "insert string:#{str} in #{path}"
      end
    end
  end

end
