RSpec.configure do |config|
  config.color = true
  config.add_formatter :documentation

  #config.before(:all) { silence_output }
  #config.after(:all) { enable_output }
end

def silence_output
  @original_stdout = $stdout
  @original_stderr = $stderr

  $stdout = File.new('./spec/stdout.txt', 'w')
  $stderr = File.new('./spec/stderr.txt', 'w')
end

def enable_output
  $stdout = @original_stdout
  @original_stdout = nil

  $stderr = @original_stderr
  @original_stderr = nil  
end


