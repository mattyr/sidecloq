require_relative 'helper'

class TestSidecloq < Sidecloq::Test
  describe 'sidecloq' do
    it 'has a version number' do
      refute_nil ::Sidecloq::VERSION
    end

    it 'is configurable by assignment' do
      Sidecloq.options[:test] = 'something'
      assert_equal Sidecloq.options[:test], 'something'
    end

    it 'is configurable by block syntax' do
      Sidecloq.configure do |options|
        options[:test_block] = 'something else'
      end

      assert_equal Sidecloq.options[:test_block], 'something else'
    end
  end
end
