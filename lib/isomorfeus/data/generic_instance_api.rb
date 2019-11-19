module Isomorfeus
  module Data
    module GenericInstanceApi
      def key
        @key
      end

      def key=(k)
        @key = k.to_s
      end

      def to_sid
        [@class_name, @key]
      end

      if RUBY_ENGINE == 'opal'
        def destroy
          promise_destroy
          nil
        end

        def promise_destroy
          self.class.promise_destroy(@key)
        end

        def reload
          self.class.promise_load(@key, self)
          self
        end

        def promise_reload
          self.class.promise_load(@key, self)
        end

        def save
          promise_save
          self
        end
        alias create save

        def promise_save
          Isomorfeus::Transport.promise_send_path( 'Isomorfeus::Data::Handler::GenericHandler', _handler_type, self.name, 'save', to_transport).then do |agent|
            if agent.processed
              agent.result
            else
              agent.processed = true
              if agent.response.key?(:error)
                `console.error(#{agent.response[:error].to_n})`
                raise agent.response[:error]
              end
              Isomorfeus.store.dispatch(type: 'DATA_LOAD', data: agent.full_response[:data])
              agent.result = true
            end
          end
        end
        alias promise_create promise_save

        def changed?
          Redux.fetch_by_path(*@_changed_store_path) ? true : false
        end

        def revision
          Redux.fetch_by_path(*@_revision_store_path)
        end
      else
        def changed?
          @_changed
        end

        def revision
          @_revision
        end
      end
    end
  end
end
