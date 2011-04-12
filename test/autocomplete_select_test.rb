require 'test/unit'
require 'autocomplete_select_helper'

class AutocompleteSelectTest < Test::Unit::TestCase
  include AutocompleteSelectHelper
  
  def test_helper_methods_included
    assert respond_to? :autocomplete_select_includes
    assert respond_to? :autocomplete_select
    assert respond_to? :autocomplete_list
  end
end
