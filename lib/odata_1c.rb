require 'active_support/core_ext/enumerable'

require 'odata_1c/version'
require 'odata_1c/connection'
require 'odata_1c/errors'
require 'odata_1c/helpers'
require 'odata_1c/property'
require 'odata_1c/properties'
require 'odata_1c/entity'
require 'odata_1c/entity_values'

module Odata1c

  # Подключается к 1С и возвращает `Connection` для дальнейшего взаимодействия с 1С
  #
  # @param (see Connection#initialize)
  # @return [Connection]
  def self.connect(host:, db_name:, user:, password: nil, verify_ssl: false, port: nil)
    Connection.new host: host,
                   db_name: db_name,
                   user: user,
                   password: password,
                   verify_ssl: verify_ssl,
                   port: port
  end
end