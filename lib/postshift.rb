require 'postshift/version'
require 'postshift/railtie' if defined?(Rails)
require 'postshift/schema'
require 'active_record/connection_adapters/redshift_adapter'

module Postshift
  @@adapter = nil

  def self.root
    File.dirname __dir__
  end

  def self.adapter=(connection_adapter)
    @@adapter = connection_adapter
  end

  def self.adapter
    @@adapter
  end

  def self.connection
    adapter.respond_to?(:raw_connection) ? adapter.raw_connection : nil
  end
end
