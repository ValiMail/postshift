require 'yaml'
require 'fileutils'
require 'pathname'

module ARTest
  class << self
    def config
      @config ||= read_config
    end

    private

    def config_file
      Pathname.new(ENV['ARCONFIG'] || TEST_ROOT + '/config.yml')
    end

    def read_config
      unless config_file.exist?
        FileUtils.cp TEST_ROOT + '/config.example.yml', config_file
      end
      YAML.parse(config_file.read).transform
    end
  end
end
