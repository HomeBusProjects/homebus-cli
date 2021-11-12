require 'homebus'

class HomebusCliOptions < Homebus::Options
  def app_options(op)
    username_help     = 'Homebus provisoning server username (usually email address)'
    password_help     = 'Homebus provisioning server password'

    op.separator 'CLI options:'
    op.on('-u', '--username USERNAME', username_help) { |value| options[:username] = value }
    op.on('-p', '--password PASSWORD_ADDRESS', password_help) { |value| options[:password] = value }
    op.separator ''
  end

  def banner
    'Homebus CLI'
  end

  def version
    '0.0.1'
  end

  def name
    'homebus-cli'
  end
end
