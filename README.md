# Capistrano::Operator

[![Gem Version](https://badge.fury.io/rb/capistrano-operator.svg)](https://badge.fury.io/rb/capistrano-operator)

It is a tool for semi-automating shell work in maintenance.
Capistrano-operator executes shell commands described by yaml operation files to the host.

It is effective in the following cases.

You want to ...
- eliminate the need to copy and paste commands from procedures.
- operate while checking the execution result with human eyes.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-operator'
```

And then execute:

    $ bundle install --deployment
    $ bundle exec cap install
    $ bundle exec operator install


## Usage

    $ bundle exec cap dev operator:apply operation={operation_filename}
    
If you want to execute the operation file name of `operations/import-sample.yml`

    $ bundle exec cap dev operator:apply operation=import-sample

### Task list

Task | Description | Argument
------|-----|------
operator:ping | Check the reachability with target host. | -
operator:check | Displays the contents of the operation specified in the argument by formatting. | operation file path
operator:apply | Execute the contents of operation specified in the argument on the target host. | operation file path

### How to make the Operation

The operation file is placed under the directory of `operaitons/`, and is described in yaml as shown below.

#### e.g. Operation file that creates a file named 'piyo.txt' and writes 'hello'.

An example of each operation is shown below. The keys for each hash are described in the following sections.

- import-sample.yml
```yaml
vars:
  filename: 'piyo.txt'
  greeting: 'hello'
tasks:
  - import: imports/touch
    vars:
      file: '{{filename}}'
  - execute_commands:
      - "echo '{{greeting}}' >> {{filename}}"
    check_commands:
      - 'ls -l'
      - 'cat {{filename}}'
    highlight:
      - 'hoge'
      - 'test'
  - import: imports/rm
```

- imports/touch.yml
```yaml
vars:
  file: 'overwrite_by_parent.txt'
tasks:
  - execute_commands:
      - "touch {{file}}"
    check_commands:
      - 'ls -l | grep {{file}}'
```

- imports/rm.yml
```yaml
vars:
  file: 'overwrite_by_parent.txt'
tasks:
  - execute_commands:
      - 'rm {{file}}'
    check_commands:
      - 'ls -l {{file}}'
```

#### vars
Describe variable definitions used in `tasks` in` vars` hash. To use the defined variable, write it in `tasks` hash in the form of` {{variable-name}} `.
The scope of the value set in `vars` hash is limited within the operation file, and does not overwrite variables defined in the imported operations.
If you need to apply variables to imported operations, please add `vars` in the same hash as `import`.

#### tasks
Describe the tasks to be executed in the `tasks` hash by array.
Before executing each tasks, the task to be executed will be displayed on the screen for confirmation.

In each tasks, you can define the operation tasks by hash object. The hash key is the type of command to execute. Select from the table below. The hash value is an array of shell commands to execute.
Not all properties are required, and a task can be formed with only one of `execute_commands`,` check_commands` and `import`.

|Property         |Description |
|:---             |:---        |
|execute_commands |Describes shell commands to be executed on the target host by array format. You can check the operation result with the choices (yes / no / reconfirm / skip) when executing each commands. After each command sexecution, it moves to the next command.|
|check_commands   |Write an array of commands to check the execution result of `execute_commands`. After executing each confirmation command, a choice (yes / no / reconfirm) will be displayed to confirm whether you can proceed to the next step. You can not execute interactive commands such as `less`.|
|import           |You can load and execute commands written in other operation files. In the above example, the command described in touch.yml in the imports directory is executed.|
|vars             |You can pass variables to the operation file to be imported by describing them in the same hash as `import`.|
|highlight        |The display of the specified string is emphasized when executing `check_commands`.|
  
### Specify target host

As with normal capistrano, specify the target host rule in the configuration file (for example, development.rb, staging.rb, production.rb, etc.) under config/deploy/ directory.

For more information, please see [the official documentation](https://github.com/capistrano/capistrano/blob/master/docs/documentation/getting-started/preparing-your-application/index.markdown) for capistrano.

#### Example

```ruby:dev.rb
server "192.168.33.10", user: "vagrant", roles: %w{any}, keys: '~/.ssh/id_rsa'
```

#### (Reference) About host configuration parameters


|Property |Description   |
|:---     |:---   |
|server   |Target host name or IP address |
|user     |Command execution user name |
|roles    |Host role |
|keys     |The authentication key required when executing a command via ssh |

## Development

    $ git clone https://github.com/iij/capistrano-operator
    $ cd capistrano-operator

### How the development environment works
launch vagrant (Target host):

    $ vagrant up

Confirming launch of vagrant:

    $ vagrant ssh
    $ ip add

If vagrant does not have an IP address of 192.168.33.10:

    $ sudo service network restart

Running capistrano:

    $ bundle install
    $ bundle update
    $ bundle exec cap dev test:ping
    (It is all right if ping:true and hostname are displayed.)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iij/capistrano-operator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
