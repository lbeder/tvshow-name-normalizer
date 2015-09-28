#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)

require 'active_support/core_ext/string'
require 'pry'
require 'lib/cli'

TVShowNameNormalizer::CLI.start(ARGV)
