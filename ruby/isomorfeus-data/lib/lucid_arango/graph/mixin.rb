module LucidArango
  module Graph
    module Mixin
      def self.included(base)
        if RUBY_ENGINE != 'opal'
          unless base == LucidArango::Graph::Base
            Isomorfeus.add_valid_data_class(base)
          end
        end

        base.include(Enumerable)
        base.extend(LucidPropDeclaration::Mixin)

        # TODO implement, depends on arango-driver
      end
    end
  end
end
