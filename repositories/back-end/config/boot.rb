ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
ENV['BUNDLE_SILENCE_ROOT_WARNING'] = '1'
ENV['BUNDLE_IGNORE_CONFIG'] = '1'

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
