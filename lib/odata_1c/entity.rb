require 'json'
require 'cgi'

module Odata1c
  # Сущность в 1С (набор сведений определённой категории).
  #
  # Как аналогию объекту сущности (инстанс {Entity}) можно рассматривать отдельную модель в ORM.
  class Entity
    attr_reader :service, :entity_name

    # @param  [Connection] service
    # @param  [String]  entity_name
    def initialize(service, entity_name)
      @service = service
      @entity_name = entity_name
    end

    # Получение списка всех наборов значений с опциональной фильтрацией на стороне 1С
    #
    # @param  [String]  filter фильтр сведений в нотации 1С,
    #                          например `"Period le 2018-12-31T00:00:00"` или `"Имя eq 'Игорь'"`
    # @param  [String, Array]  select выборка необходимых полей в запросе,
    #                          например `"Объект,Объект_Type,НомерВерсии,ДатаВерсии"`
    # @return [Array<EntityValues>]
    def list(filter = '', select: '')
      q = {'$format' => 'json'}
      q['$filter'] = filter unless filter.empty?
      q['$select'] = prepare_select(select) unless select.empty?

      params_hash = build_query q
      query       = Addressable::URI.parse('?' + params_hash).normalize.to_s
      uri         = url(query)
      data        = Helpers.convert_to_nil JSON.parse(service.execute_request(uri, 'get').body)['value']
      build_response(data)
    end

    # Получение одного набора значений
    #
    # @param  [String|Hash] arg
    # @return [EntityValues]
    def get(arg)
      query = self.class.detect_arg(arg)
      uri = url(CGI.escape(query) + '?$format=json')
      response = service.execute_request(uri, 'get').body
      EntityValues.new(self, Helpers.convert_to_nil(JSON.parse(response)))
    end

    # Создание объекта
    #
    # @param  [Hash] arg - атрибуты объекта
    # @return [EntityValues]
    def write(arg)
      raise InvalidArgumentError.new('Argument must be Hash only!') unless arg.kind_of?(Hash)
      raise InvalidArgumentError.new('Argument can\'t be empty!') if arg.empty?
      validate_arg(arg)
      data = JSON.dump(arg)
      uri = url('?$format=json')
      response = service.execute_request(uri, 'post', payload: data, headers: { content_type: 'application/json' })
      EntityValues.new(self, JSON.parse(response.body)) if response
    end

    # Обновление объекта
    #
    # @param  [String] ref_key
    # @param  [Hash] data
    # @return [EntityValues]
    def update(ref_key, data={})
      raise InvalidArgumentError.new('Argument must be Hash only!') unless data.kind_of?(Hash)
      validate_arg(data)

      data     = JSON.dump(data)
      entity   = Addressable::URI.parse(ref_key).normalize.to_s
      uri      = url("(#{entity})?$format=json")
      response = service.execute_request(uri, :patch, payload: data, headers: { content_type: 'application/json' })
      EntityValues.new(self, JSON.parse(response.body)) if response
    end

    # Вызов операции для обекта сущности
    #
    # @example
    #
    #   entity.perform '123', 'Operation' # => отправит запрос `POST .../EntityName('123')/Operation()`
    #
    # @param [String] ref_key
    # @param [String] method_name
    def perform(ref_key, method_name)
      ref_key = Addressable::URI.parse(ref_key).normalize.to_s
      uri = url("(#{ref_key})/#{method_name}()?$format=json")
      service.execute_request(uri, :post)
      true
    end


    # @api private
    # @return [Array<EntityValues>]
    def build_response(response)
      response.map {|values| EntityValues.new self, values}
    end

    def url(str='')
      Addressable::URI.parse(service.service_url + '/' + entity_name).normalize.to_s + str
    end

    def build_query(hash)
      query_str = Addressable::URI.new
      query_str.query_values = hash
      query_str.query
    end

    def self.detect_arg(arg)
      case arg
      when String
        "('#{arg}')"
      when Hash
        params_mass = []
        arg.keys.each do |key|
          str = (key.to_s + '=' + "'" + arg[key].to_s + "'")
          params_mass.append(str)
        end
        '(' + params_mass.join(", ") + ')'
      end
    end

    # @return [Properties]
    def properties
      @properties ||= service.metadata[entity_name]
    end

    private

    def validate_arg(arg)
      arg.keys.each do |key|
        raise(InvalidArgumentError.new("Argument '#{key}' (#{arg}) must be included in metadata!")) unless properties.include?(key)
      end
    end

    def prepare_select(select)
      case select
      when Array
        select.join(',')
      when String
        select
      end
    end
  end
end
