require 'active_support/logger'

module ARTest
  def self.connect
    ActiveRecord::Base.logger = ActiveSupport::Logger.new('debug.log', 0, 100 * 1024 * 1024)
    ActiveRecord::Base.establish_connection(config['test'])
  end
end
