LINT_IGNORES = ['rvm']
 
namespace :ci do 
  desc "Check YAML file structure."
  task :yaml_checker do
    begin
      require 'yaml'
    rescue LoadError
      fail 'Cannot load yaml, did you install it?'
    end

    FileList['**/*.yaml'].each do |puppet_file|
      begin
        puts "Checking #{puppet_file}.."
        YAML.load_file(puppet_file)
      rescue SyntaxError, Exception => e
        abort "Could not parse YAML:#{e.message}"
      end
    end
  end

  desc "Check puppet module code style."
  task :lint do
    begin
      require 'puppet-lint'
    rescue LoadError
      fail 'Cannot load puppet-lint, did you install it?'
    end
 
    success = true
 
    linter = PuppetLint.new
    linter.configuration.log_format =
        '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}'
 
    lintrc = ".puppet-lintrc"
    if File.file?(lintrc)
      File.read(lintrc).each_line do |line|
        check = line.sub(/--no-([a-zA-Z0-9_]*)-check/, '\1').chomp
        linter.configuration.send("disable_#{check}")
      end
    end
 
    FileList['**/*.pp'].each do |puppet_file|
      if puppet_file.start_with? 'modules'
        parts = puppet_file.split('/')
        module_name = parts[1]
        next if LINT_IGNORES.include? module_name
      end
 
      puts "Evaluating code style for #{puppet_file}"
      linter.file = puppet_file
      linter.run
      success = false if linter.errors?
    end
 
    abort "[INFO] Checking puppet module code style FAILED" if success.is_a?(FalseClass)

  end
end
