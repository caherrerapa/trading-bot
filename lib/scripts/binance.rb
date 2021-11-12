#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require "#{File.dirname __FILE__}/../../config/environment"

trader = Trader::Binance.new
trader.listen!
