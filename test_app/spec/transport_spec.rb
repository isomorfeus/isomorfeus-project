require 'spec_helper'

RSpec.describe 'isomorfeus-transport' do
  before :all do
    @doc = visit('/')
  end

  it 'is loaded' do
    result = @doc.evaluate_ruby do
      defined? Isomorfeus::Transport
    end
    expect(result).to eq 'constant'
  end

  it 'configuration is accessible on the client' do
    result = @doc.evaluate_ruby do
      Isomorfeus.api_websocket_path
    end
    expect(result).to eq '/isomorfeus/api/websocket'
  end

  it 'configuration is accessible on the server' do
    expect(Isomorfeus.api_websocket_path).to eq '/isomorfeus/api/websocket'
    expect(Isomorfeus.middlewares).to include(Isomorfeus::Transport::RackMiddleware)
  end

  it 'connected during client app boot' do
    CONNECTING  = 0
    OPEN        = 1
    CLOSING     = 2
    CLOSED      = 3
    socket_state = nil
    start = Time.now
    while socket_state != OPEN do
      socket_state = @doc.evaluate_ruby do
        Isomorfeus::Transport.socket.ready_state
      end
      if socket_state != OPEN
        break if Time.now - start > 60
        sleep 1
      end
    end
    expect(socket_state).to eq(1)
  end

  it 'can subscribe to a channel' do
    result = @doc.await_ruby do
      class TestChannel < LucidChannel::Base
      end

      TestChannel.subscribe
    end
    expect(result).to have_key('success')
    expect(result['success']).to eq('TestChannel')
  end

  it 'can unsubscribe from a channel' do
    result = @doc.await_ruby do
      class TestChannel < LucidChannel::Base
      end

      TestChannel.unsubscribe
    end
    expect(result).to have_key('success')
    expect(result['success']).to eq('TestChannel')
  end
end