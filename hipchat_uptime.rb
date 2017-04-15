require 'hipchat'
require 'yaml'





def send_screenshot_to_user
  user.send(message, message_format: 'html')

  screenshot = capture_screen
  if !screenshot.nil?
    user.send_file('', File.open(screenshot.path))
  else
    user.send('<i>failed to capture screenshot</i>', 'html')
  end
end

def capture_screen
  file = Pathname.new(config['screenshot_path']).join("#{DateTime.now.strftime('%Y%m%d_%H%M%S')}.png")
  `/usr/sbin/screencapture -x -t png #{file.to_s}`
  if file.exist?
    File.new(file.to_path)
  else
    nil
  end
end

def client
  @client ||= HipChat::Client.new(config['token'], api_version: 'v2', message_format: 'html')
end

def user
  @user ||= client.user(config['send_to_user'])
end

def send_as
  @send_as ||= (host = `hostname -s`.strip; user = `whoami`.strip; "#{user}:#{host}")
end

def message
  <<-MSG
    <p><b>Uptime</b></p>
    <p>#{uptime}</p>
    <p><b>IP info :</b></p>
    <p>
      <ul>
        #{ip_addresses.split(/\n\t?/).map{|s| "<li>#{s}</li>"}.join}
      </ul>
    </p>
  MSG
end

def ip_addresses
  @ip_addresses ||= `/sbin/ifconfig | grep inet`.strip
end

def uptime
  @uptime ||= `/usr/bin/uptime`.strip
end

def delete_screenshots(older_than = (DateTime.now - 15).to_time)
  Dir.entries(config['screenshot_path'])
     .map{|f| File.expand_path(f, config['screenshot_path'])}
     .select{|f| File.file?(f) && File.ctime(f) < older_than}
     .each do |f|
    File.delete(f)
  end
end

def config
  @config ||= read_config
end

def read_config
  cfg_file = File.join(File.expand_path(File.dirname(__FILE__)), 'config.yml')
  YAML.load(File.read(cfg_file))
end



send_screenshot_to_user()
delete_screenshots()