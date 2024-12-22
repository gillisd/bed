module Bed
  class Builder
    def initialize(schema, &block)
      @schema = schema
    end

    def define_methods
      @schema.deconstruct_keys(nil).each do |key, value|
        case value
        in Data
          Bed::Builder.new()
        end

      end
    end

    def member?(name)
      @schema.members.include?(name)
    end


  end
end