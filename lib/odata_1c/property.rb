module Odata1c
  # Свойста значения одного из ключей объекта
  class Property
    # Тип объекта (например, `"Edm.String"`)
    #
    # @return [String]
    attr_reader :type

    # Название объекта (например, `"Name"`)
    #
    # @return [String]
    attr_reader :name

    # Может ли значение объекта быть опущено
    #
    # @return [TrueClass, FalseClass]
    attr_reader :nullable

    # @param  [String] type     (see #type)
    # @param  [String] name     (see #name)
    # @param  [TrueClass, FalseClass] nullable  (see #nullable)
    def initialize(type:, name:, nullable:)
      @type, @name, @nullable = type, name, nullable
    end

    # (see #nullable)
    def nullable?
      nullable
    end

    # @return [TrueClass, FalseClass]
    def ==(another_property)
      return false unless self.class === another_property
      another_property.type == type && another_property.name == name && another_property.nullable == nullable
    end

    # @return [TrueClass, FalseClass]
    def eql?(another_property)
      return false unless self.class == another_property.class
      self == another_property
    end
  end
end