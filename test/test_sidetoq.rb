require_relative 'helper'

class TestSidecloq < Sidecloq::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sidecloq::VERSION
  end
end
