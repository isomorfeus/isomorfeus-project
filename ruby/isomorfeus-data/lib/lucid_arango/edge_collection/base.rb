module LucidArango
  module EdgeCollection
    class Base
      include LucidArango::EdgeCollection::Mixin

      if RUBY_ENGINE != 'opal'
        def self.inherited(base)
          Isomorfeus.add_valid_data_class(base)
        end
      end
    end
  end
end
