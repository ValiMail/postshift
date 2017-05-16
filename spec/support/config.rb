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
      Pathname.new(ENV['ARCONFIG'] || 'spec/config.yml')
    end

    def read_config
      unless config_file.exist?
        FileUtils.cp 'spec/config.example.yml', config_file
      end
      YAML.parse(config_file.read).transform
    end
  end
end
