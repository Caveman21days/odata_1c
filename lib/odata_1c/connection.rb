# connection setup
require 'addressable/uri'
require 'rest-client'
require 'uri'
require 'nokogiri'

# TODO: Refactor the current code structure

module Odata1c
  # Соединение для дальнейшего взаимодействия с 1С
  class Connection
    attr_reader :host, :db_name, :user, :password, :verify_ssl, :port, :service_url, :metadata

    # Метаданные
    #
    # В качестве ключа указывается название набора значений (`String`).
    # В качестве значение указываются свойства объектов данного набора значений (`Properties`).
    class Metadata < Hash
    end

    # {include:Connection}
    #
    # Успешное создание соединение означает успешное проведение запроса метаданных к серверу 1С.
    #
    # @param  [String] host
    # @param  [String] db_name
    # @param  [String] user
    # @param  [String, NilClass] password (nil)
    # @param  [TrueClass, FalseClass] verify_ssl (false)
    # @param  [String, NilClass] port (nil)
    # @raise  (see #get_metadata)
    def initialize(host:, db_name:, user:, password: nil, verify_ssl: false, port: nil)
      @host        = host
      @db_name     = db_name
      @user        = user
      @password    = password || ''
      @verify_ssl  = verify_ssl
      @port        = port || ''
      @service_url = Helpers.connection_url(host, port, db_name, verify_ssl)
      @metadata  ||= get_metadata
    end

    # @api private
    def execute_request(url, method='get', params={})
      request_params = { method: method, url: url, user: user, password: password }.merge(params)
      begin
        RestClient::Request.execute(request_params)
      rescue RestClient::Exceptions::OpenTimeout, StandardError => e
        raise Odata1c.process_response(e)
      end
    end

    # @api private
    def url
      service_url
    end

    # Получение сущности (набора сведений) определённой категории
    #
    # @param  [String]  entity_name
    # @raise  [UnknownEntityError]  если `entity_name` не поддерживается 1С
    # @raise  [Error] другие ошибки взаимодействия с 1С
    # @return [Entity]
    def [](entity_name)
      metadata.key?(entity_name) ? Entity.new(self, entity_name) : raise(UnknownEntityError.new("Entity '#{entity_name}' does not exist in metadata"))
    end

    private

    # @api private
    # @raise  [Error] ошибки взаимодействия с 1С
    def get_metadata
      xml_str = execute_request(url + '/$metadata', 'get')
      xml = Nokogiri::XML(xml_str).remove_namespaces!
      metadata = Metadata.new

      xml.xpath("//EntityType").each do |e|
        properties_array = e.css("Property").map do |p|
          Property.new name: p.attributes['Name'].value,
                       type: p.attributes['Type'].value,
                       nullable: (p.attributes['Nullable'].value == 'true')
        end

        metadata[e.attributes["Name"].value] = Properties.new *properties_array
      end
      metadata
    end
  end
end
