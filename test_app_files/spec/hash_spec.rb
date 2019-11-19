require 'spec_helper'

RSpec.describe 'LucidHash' do
  context 'on the server' do
    it 'can instantiate a hash by inheritance' do
      result = on_server do
        class TestHashBase < LucidHash::Base
        end
        hash = TestHashBase.new(key: 1, attributes: { test: 1, experiment: 2 })
        hash.count
      end
      expect(result).to eq(2)
    end

    it 'can instantiate a hash by mixin' do
      result = on_server do
        class TestHashMixin
          include LucidHash::Mixin
        end
        hash = TestHashMixin.new(key: 2, attributes: { test: 1, experiment: 2, probe: 3 })
        hash.count
      end
      expect(result).to eq(3)
    end

    it 'verifies attribute :test, class' do
      result = on_server do
        class TestHashC < LucidHash::Base
          attribute :test, class: String
        end
        hash = TestHashC.new(key: 3, attributes: { test: 'a_string' })
        hash.test.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestHashC < LucidHash::Base
          attribute :test, class: String
        end
        begin
          TestHashC.new(key: 4, attributes: { test: 1 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestHashC < LucidHash::Base
          attribute :test, class: String
        end
        begin
          hash = TestHashC.new(key: 5)
          hash.test = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute :test, is_a' do
      result = on_server do
        class TestHashD < LucidHash::Base
          attribute :test, is_a: String
        end
        hash = TestHashD.new(key: 5, attributes: { test: 'a_string' })
        hash.test.class.name
      end
      expect(result).to eq('String')
      result = on_server do
        class TestHashD < LucidHash::Base
          attribute :test, is_a: String
        end
        begin
          TestHashD.new(key: 6, attributes: { test: 1 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = on_server do
        class TestHashD < LucidHash::Base
          attribute :test, is_a: String
        end
        begin
          node = TestHashD.new(key: 7)
          node.test = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = on_server do
        class TestHashE < LucidHash::Base
        end
        hash = TestHashE.new(key: 8)
        hash.changed?
      end
      expect(result).to be(false)
      result = on_server do
        class TestHashE < LucidHash::Base
        end
        hash = TestHashE.new(key: 9)
        hash[:test] = 20
        hash.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = on_server do
        class TestHashE < LucidHash::Base
        end
        hash = TestHashE.new(key: 10)
        hash.to_sid
      end
      expect(result).to eq(['TestHashE', '10'])
    end

    it 'can validate a attribute :test,' do
      result = on_server do
        class TestHashF < LucidHash::Base
          attribute :test, class: String
        end
        TestHashF.valid_attribute?(:test, 10)
      end
      expect(result).to eq(false)
      result = on_server do
        class TestHashF < LucidHash::Base
          attribute :test, class: String
        end
        TestHashF.valid_attribute?(:test, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = on_server do
        class TestHashG < LucidHash::Base
        end
        hash = TestHashG.new(key: 13, attributes: { test: 1, experiment: 2, probe: 3 })
        JSON.dump(hash.to_transport)
      end
      expect(JSON.load(result)).to eq("hashes"=>{"TestHashG"=>{"13"=>{"test"=>1,"experiment"=>2,"probe"=>3}}})
    end
  end

  context 'on the client' do
    before :each do
      @doc = visit('/')
    end

    it 'can instantiate a hash by inheritance' do
      result = @doc.evaluate_ruby do
        class TestHashBase < LucidHash::Base
        end
        hash = TestHashBase.new(key: 1, attributes: { test: 1, experiment: 2 })
        hash.count
      end
      expect(result).to eq(2)
    end

    it 'can instantiate a hash by mixin' do
      result = @doc.evaluate_ruby do
        class TestHashMixin
          include LucidHash::Mixin
        end
        hash = TestHashMixin.new(key: 2, attributes: { test: 1, experiment: 2, probe: 3 })
        hash.count
      end
      expect(result).to eq(3)
    end

    it 'verifies attribute :test, class' do
      result = @doc.evaluate_ruby do
        class TestHashC < LucidHash::Base
          attribute :test, class: String
        end
        hash = TestHashC.new(key: 3, attributes: { test: 'a_string' })
        hash.test.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestHashC < LucidHash::Base
          attribute :test, class: String
        end
        begin
          TestHashC.new(key: 4, attributes: { test: 1 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestHashC < LucidHash::Base
          attribute :test, class: String
        end
        begin
          hash = TestHashC.new(key: 5)
          hash.test = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'verifies if attribute :test, is_a' do
      result = @doc.evaluate_ruby do
        class TestHashD < LucidHash::Base
          attribute :test, is_a: String
        end
        hash = TestHashD.new(key: 5, attributes: { test: 'a_string' })
        hash.test.class.name
      end
      expect(result).to eq('String')
      result = @doc.evaluate_ruby do
        class TestHashD < LucidHash::Base
          attribute :test, is_a: String
        end
        begin
          TestHashD.new(key: 6, attributes: { test: 1 })
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
      result = @doc.evaluate_ruby do
        class TestHashD < LucidHash::Base
          attribute :test, is_a: String
        end
        begin
          node = TestHashD.new(key: 7)
          node.test = 10
        rescue
          'exception thrown'
        end
      end
      expect(result).to eq('exception thrown')
    end

    it 'reports a change' do
      result = @doc.evaluate_ruby do
        class TestHashE < LucidHash::Base
        end
        hash = TestHashE.new(key: 8)
        hash.changed?
      end
      expect(result).to be(false)
      result = @doc.evaluate_ruby do
        class TestHashE < LucidHash::Base
        end
        hash = TestHashE.new(key: 9)
        hash[:test] = 20
        hash.changed?
      end
      expect(result).to be(true)
    end

    it 'converts to cid' do
      result = @doc.evaluate_ruby do
        class TestHashE < LucidHash::Base
        end
        hash = TestHashE.new(key: 10)
        hash.to_sid
      end
      expect(result).to eq(['TestHashE', '10'])
    end

    it 'can validate a attribute :test,' do
      result = @doc.evaluate_ruby do
        class TestHashF < LucidHash::Base
          attribute :test, class: String
        end
        TestHashF.valid_attribute?(:test, 10)
      end
      expect(result).to eq(false)
      result = @doc.evaluate_ruby do
        class TestHashF < LucidHash::Base
          attribute :test, class: String
        end
        TestHashF.valid_attribute?(:test, '10')
      end
      expect(result).to eq(true)
    end

    it 'converts to transport' do
      result = @doc.evaluate_ruby do
        class TestHashG < LucidHash::Base
        end
        hash = TestHashG.new(key: 13, attributes: { test: 1, experiment: 2, probe: 3 })
        JSON.dump(hash.to_transport)
      end
      expect(JSON.parse(result)).to eq("hashes"=>{"TestHashG"=>{"13"=>{"test"=>1,"experiment"=>2,"probe"=>3}}})
    end
  end
end
