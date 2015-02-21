require './test/minitest_helper'

module CheckstyleFilter
  class TestGit < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::CheckstyleFilter::Git::VERSION
    end
  end
end
