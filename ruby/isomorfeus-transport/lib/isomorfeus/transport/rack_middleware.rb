# frozen_string_literal: true

module Isomorfeus
  module Transport
    class RackMiddleware
      WS_RESPONSE = [0, {}, []]

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == Isomorfeus.api_websocket_path
          if env['rack.upgrade?'] == :websocket
            env['rack.upgrade'] = Isomorfeus::Transport::ServerSocketProcessor.new
          end
          WS_RESPONSE
        elsif env['PATH_INFO'] == Isomorfeus.cookie_eater_path
          cookie_accessor, new_path = env['QUERY_STRING'].split('=')
          cookie = Isomorfeus.session_store.take_cookie(accessor: cookie_accessor)
          if new_path.start_with?('/')
            if cookie
              [302, { 'Location' => new_path, 'Set-Cookie' => cookie }, ["Cookie eaten!"]]
            else
              [302, { 'Location' => new_path }, ["No Cookie!"]]
            end
          else
            [404, {}, ["Must specify relative path!"]]
          end
        else
          cookies = env['HTTP_COOKIE']
          if cookies
            cookies = cookies.split('; ')
            cookie = cookies.detect { |c| c.start_with?('session=') }
            if cookie
              session_id = cookie[8..-1]
              user = Isomorfeus.session_store.get_user(session_id: session_id)
              if user
                Thread.current[:isomorfeus_user] = user
                Thread.current[:isomorfeus_session_id] = session_id
              end
            end
          end
          begin
            result = @app.call(env)
          ensure
            Thread.current[:isomorfeus_user] = nil
            Thread.current[:isomorfeus_session_id] = nil
          end
          result
        end
      end
    end
  end
end
