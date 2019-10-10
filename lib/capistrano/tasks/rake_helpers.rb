require 'sshkit/interactive'
require 'color_echo'

def exception_handling
  begin
    yield
  rescue SSHKit::Command::Failed => e
    error e
    e.inspect.each_line do |line|
      return line.chomp! if line =~ /stderr/
    end
  end
end

def try_to_execute(cmd)
  exception_handling { execute cmd }
end

def try_to_capture(cmd)
  exception_handling { capture cmd }
end

def raise_error_with_usage(msg)
  STDERR.puts(msg)
  usage
  exit 1
end

def usage
  puts '(e.g. bundle exec cap staging operator:apply operation=sample)'
end

def warn_highlight
  CE.once.ch_fg(:red)
  yield
end

def enable_highlight(strings)
  strings.each do |string|
    CE.pickup(string, :h_red, nil, :bold)
  end
end

def disable_highlight
  CE.reset(:pickup)
end
