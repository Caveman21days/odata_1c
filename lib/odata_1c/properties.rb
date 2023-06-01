module Odata1c
  # Свойства объекта (свойства значений всех ключей объекта)
  class Properties
    include Enumerable

    # @param  [Array<Property>] properties
    def initialize(*properties)
      @properties = properties.index_by {|property| property.name}
    end

    # @yieldparam [Property]  свойство
    def each(&block)
      to_a.each &block
    end

    # @return [Array<Property>]
    def to_a
      properties.values
    end

    # @return (see #properties)
    def to_h
      properties.dup
    end

    # Проверка наличия данного значения или значения с данным названием свойства
    #
    # @param  [String, Property]  property_or_name
    # @return [TrueClass, FalseClass]
    def include?(property_or_name)
      case property_or_name
      when String
        properties.key? property_or_name
      when Property
        properties.values.include? property_or_name
      else
        false
      end
    end

    # Свойства значения по названию свойства
    #
    # @param  [String]  property_name
    # @return [Trueclass, FalseClass]
    def [](property_name)
      properties[property_name]
    end

    private
    # @return [Hash{String => Property}]
    attr_reader :properties
  end
end