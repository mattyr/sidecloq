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
  end
end
