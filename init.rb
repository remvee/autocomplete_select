require 'autocomplete_select_helper'

Mime::Type.register "text/plain", :autocomplete

ActionController::Base.helper AutocompleteSelectHelper
