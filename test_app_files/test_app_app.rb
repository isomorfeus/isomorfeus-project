require_relative 'app_loader'
require_relative 'owl_init'
require_relative 'iodine_config'


class TestAppApp < Roda
  extend Isomorfeus::Transport::Middlewares
  include OpalWebpackLoader::ViewHelper
  include Isomorfeus::ReactViewHelper

  use_isomorfeus_middlewares
  plugin :public, root: 'public'

  def page_content(host, location)
    <<~HTML
      <html>
        <head>
          <title>Welcome to TestAppApp</title>
          #{owl_script_tag 'application.js'}
        </head>
        <body>
          #{mount_component('TestAppApp', location_host: host, location: location)}
        </body>
      </html>
    HTML
  end

  route do |r|
    r.root do
      page_content(env['HTTP_HOST'], '/')
    end

    r.public

    r.get 'favicon.ico' do
      r.public
    end

    r.get 'ssr' do
      <<~HTML
        <html>
          <head>
            <title>Welcome to TestAppApp</title>
          </head>
          <body>
            #{mount_component('TestAppApp', location_host: env['HTTP_HOST'],  location: env['PATH_INFO'])}
            <div id="test_anchor"></div>
          </body>
        </html>
      HTML
    end

    r.get do
      content = page_content(env['HTTP_HOST'], env['PATH_INFO'])
      response.status = ssr_response_status
      content
    end
  end
end
