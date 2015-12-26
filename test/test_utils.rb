require_relative 'helper'

class TestUtils < Sidecloq::Test
  class TestClass
    include Sidecloq::Utils
  end

  describe 'utils' do
    let(:utils) { TestClass.new }

    describe 'will_never_run' do
      it 'detects runnable cron lines' do
        refute utils.will_never_run('* * * * *')
      end

      it 'detects impossible cron lines' do
        assert utils.will_never_run('0 5 31 2 *')
      end
    end

    describe 'redis connection' do
      it 'works in block form' do
        utils.redis do |r|
          refute_nil r
        end
      end

      it 'works in non-block form' do
        r = utils.redis
        refute_nil r
      end
    end
  end
end
