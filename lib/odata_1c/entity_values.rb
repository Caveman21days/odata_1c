module Odata1c
  # Один набор значений сущности {Entity}
  class EntityValues
    attr_reader :entity, :values

    def initialize(entity, values)
      @entity = entity
      @values = values
    end

    # Получение значения по ключу `property_name`
    #
    # @param  [String] property_name ключ в `values`
    # @raise (see #property!)
    # @return (see #typecast)
    def [](property_name)
      typecast property!(property_name), values[property_name]
    end

    # Значения всех свойств (ключей)
    #
    # @return [Hash{String => String|NilClass|Time}]
    def to_h
      entity.properties.inject({}) do |result, property|
        result[property.name] = typecast property, values[property.name]
        result
      end
    end
    private

    # @param  [String]  property_name
    # @raise  [UnknownAttributeError] если передан неизвестный `property_name`
    # @return [Property]
    def property!(property_name)
      entity.properties[property_name] || raise(UnknownAttributeError.new("value '#{property_name}' does not exist"))
    end

    # Приведение "сырого" значения к типу, соответствующему типу из описания свойств значения.
    #
    # Производит дополнительную обработку "пустых" значения дат и идентификаторов: приводит непустые значения `raw_value`
    # к `nil` в ситуациях, когда значение `raw_value` подразумевает отсуствие значения.
    #
    # @param  [Property]  property описание свойств значения
    # @param  [String, NilClass]  raw_value сырое значение
    # @return [String, NilClass]
    # @return [Time]  для дат (разбор производится в текущем часовом поясе)
    def typecast(property, raw_value)
      return nil if raw_value.nil?

      case property.type
      when 'Edm.DateTime'
        raw_value == '0001-01-01T00:00:00' ? nil : Time.parse(raw_value)
      when 'Edm.Guid'
        raw_value == '00000000-0000-0000-0000-000000000000' ? nil : raw_value
      else
        raw_value
      end
    end
  end
end