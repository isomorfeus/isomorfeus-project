module LucidData
  module Edge
    module Mixin
      def self.included(base)
        base.include(Isomorfeus::Data::AttributeSupport)
        base.extend(Isomorfeus::Data::GenericClassApi)
        base.include(Isomorfeus::Data::GenericInstanceApi)

        def changed?
          @_changed
        end

        def changed!
          @_collection.changed! if @_collection
          @_composition.changed! if @_composition
          @_changed = true
        end

        def collection
          @_collection
        end

        def collection=(c)
          @_collection = c
        end

        def graph
          @_collection&.graph
        end

        def composition
          @_composition
        end

        def composition=(c)
          @_composition = c
        end

        def other(node)
          other_from = from
          other_to = to
          return other_to if other_from == node
          other_from if other_to == node
        end

        def from
          graph&.node_from_sid(from_as_sid)
        end

        def to
          graph&.node_from_sid(to_as_sid)
        end

        def to_transport
          hash = { "attributes" => _get_selected_attributes,
                   "from" => from_as_sid,
                   "to" => to_as_sid }
          hash.merge!("revision" => revision) if revision
          result = { @class_name => { @key => hash }}
          result.deep_merge!(@class_name => { @previous_key => { new_key: @key}}) if @previous_key
          result
        end

        if RUBY_ENGINE == 'opal'
          def initialize(key:, revision: nil, from: nil, to: nil, attributes: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            _update_paths
            @_revision = revision ? revision : Redux.fetch_by_path(:data_state, @class_name, @key, :revision)
            @_collection = collection
            @_composition = composition
            @_changed = false
            loaded = loaded?
            if attributes
              _validate_attributes(attributes)
              if loaded
                raw_attributes = Redux.fetch_by_path(*@_store_path)
                if `raw_attributes === null`
                  @_changed_attributes = !attributes ? {} : attributes
                elsif raw_attributes && !attributes.nil? && ::Hash.new(raw_attributes) != attributes
                  @_changed_attributes = attributes
                end
              else
                @_changed_attributes = attributes
              end
            else
              @_changed_attributes = {}
            end
            from = from.to_sid if from.respond_to?(:to_sid)
            if loaded && from
              @_changed_from = nil
              store_from = Redux.fetch_by_path(*@_from_path)
              @_changed_from = from unless `from == store_from`
            else
              @_changed_from = from
            end
            to = to.to_sid if to.respond_to?(:to_sid)
            if loaded && to
              @_changes_to = nil
              store_to = Redux.fetch_by_path(*@_to_path)
              @_changed_to = to unless `to == store_to`
            else
              @_changed_to = to
            end
          end

          def _load_from_store!
            @_changed_attributes = {}
            @_changed_from = nil
            @_changed_to = nil
            @_changed = false
          end

          def _update_paths
            @_store_path = [:data_state, @class_name, @key, :attributes]
            @_from_path = [:data_state, @class_name, @key, :from]
            @_to_path = [:data_state, @class_name, @key, :to]
          end

          def each(&block)
            attributes.each(&block)
          end

          def [](name)
            _get_attribute(name)
          end

          def []=(name, val)
            _validate_attribute(name, val)
            changed!
            @_changed_attributes[name] = val
          end

          def from_as_sid
            @_changed_from ? @_changed_from : Redux.fetch_by_path(*@_from_path)
          end

          def from=(node)
            changed!
            old_from = from
            if node.respond_to?(:to_sid)
              @_changed_from = node.to_sid
            else
              @_changed_from = node
              node = Isomorfeus.instance_from_sid(node)
            end
            @_collection.update_node_to_edge_cache(self, old_from, node) if @_collection
            node
          end

          def to_as_sid
            @_changed_to ? @_changed_to : Redux.fetch_by_path(*@_to_path)
          end

          def to=(node)
            changed!
            old_to = to
            if node.respond_to?(:to_sid)
              @_changed_to = node.to_sid
              node
            else
              @_changed_to = node
              node = Isomorfeus.instance_from_sid(node)
            end
            @_collection.update_node_to_edge_cache(self, old_to, node) if @_collection
            node
          end
        else # RUBY_ENGINE
          Isomorfeus.add_valid_data_class(base) unless base == LucidData::Edge::Base || base == LucidData::Link::Base

          base.instance_exec do
            def instance_from_transport(instance_data, included_items_data)
              key = instance_data[self.name].keys.first
              revision = instance_data[self.name][key].key?('revision') ? instance_data[self.name][key]['revision'] : nil
              attributes = instance_data[self.name][key].key?('attributes') ? instance_data[self.name][key]['attributes'].transform_keys!(&:to_sym) : nil
              from_node_sid = instance_data[self.name][key].key?('from') ? instance_data[self.name][key]['from'] : nil
              to_node_sid = instance_data[self.name][key].key?('to') ? instance_data[self.name][key]['to'] : nil
              from_to = []
              if from_node_sid && to_node_sid
                [from_node_sid, to_node_sid].each do |sid|
                  node_class_name = sid[0]
                  node_key = sid[1]
                  Isomorfeus.raise_error(message: "#{self.name}: #{node_class_name}: Not a valid LucidData class!") unless Isomorfeus.valid_data_class_name?(node_class_name)
                  if included_items_data.key?(node_class_name) && included_items_data[node_class_name].key?(node_key)
                    node_class = Isomorfeus.cached_data_class(node_class_name)
                    Isomorfeus.raise_error(message: "#{self.name}: #{node_class_name}: Cannot get class!") unless node_class
                    node = node_class.instance_from_transport({ node_class_name => { node_key => included_items_data[node_class_name][node_key] }}, included_items_data)
                    Isomorfeus.raise_error(message: "#{self.name}: #{node_class_name} with key #{node_key} could not be extracted from transport data!") unless node
                    from_to << node
                  end
                end
              end
              new(key: key, revision: revision, attributes: attributes, from: from_to[0], to: from_to[1])
            end
          end

          def initialize(key:, revision: nil, from:, to:, attributes: nil, collection: nil, composition: nil)
            @key = key.to_s
            @class_name = self.class.name
            @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
            @_revision = revision
            @_composition = composition
            @_changed = false
            @_collection = collection
            attributes = {} unless attributes
            _validate_attributes(attributes) if attributes
            @_raw_attributes = attributes
            @_changed_from = nil
            @_changed_to = nil
            @_raw_from = if from.respond_to?(:to_sid)
                           from.to_sid
                         else
                           from[1] = from[1].to_s
                           from
                         end
            @_raw_to = if to.respond_to?(:to_sid)
                         to.to_sid
                       else
                         to[1] = to[1].to_s
                         to
                       end
          end

          def _unchange!
            @_changed =false
          end

          def each(&block)
            @_raw_attributes.each(&block)
          end

          def [](name)
            @_raw_attributes[name]
          end

          def []=(name, val)
            _validate_attribute(name, val)
            changed!
            @_raw_attributes[name] = val
          end

          def from_as_sid
            @_changed_from ? @_changed_from : @_raw_from
          end

          def from=(node)
            Isomorfeus.raise_error(message: "A invalid 'from' was given") unless node
            changed!
            old_from = from
            if node.respond_to?(:to_sid)
              node_sid = node.to_sid
            else
              node_sid = node
              node_sid[1] = node_sid[1].to_s
              node = graph.node_from_sid(node_sid)
            end
            @_changed_from = node_sid
            @_collection.update_node_to_edge_cache(self, old_from, node) if @_collection
            node
          end

          def to_as_sid
            @_changed_to ? @_changed_to : @_raw_to
          end

          def to=(node)
            Isomorfeus.raise_error(message: "A invalid 'to' was given") unless node
            old_to = to
            changed!
            if node.respond_to?(:to_sid)
              node_sid = node.to_sid
            else
              node_sid = node
              node_sid[1] = node_sid[1].to_s
              node = graph.node_from_sid(node_sid)
            end
            @_changed_to = node_sid
            @_collection.update_node_to_edge_cache(self, old_to, node) if @_collection
            node
          end
        end # RUBY_ENGINE
      end
    end
  end
end
