require 'postshift/version'
require 'postshift/railtie' if defined?(Rails)
require 'postshift/schema'
require 'active_support'
require 'active_support/core_ext/module/attribute_accessors_per_thread'
require 'active_record/connection_adapters/redshift_adapter'

module Postshift
  thread_mattr_accessor :adapter

  def self.root
    File.dirname __dir__
  end

  def self.connection
    adapter.respond_to?(:raw_connection) ? adapter.raw_connection : nil
  end
end
