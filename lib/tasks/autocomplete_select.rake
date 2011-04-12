namespace :autocomplete_select do
  desc "Install assets for AutocompleteSelect in public directory"
  task :install_assets => :environment do
    require 'fileutils'
    dest = "#{RAILS_ROOT}/public/javascripts/autocomplete_select"
    FileUtils.mkdir_p dest
    FileUtils.cp "#{File.dirname(__FILE__)}/../../assets/autocomplete_select.js", dest
  end
end
