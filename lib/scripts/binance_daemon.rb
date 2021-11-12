#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'daemons'

options = {
  log_output:         true,
  backtrace:          true,
  monitor:            true,
  multiple:           false,
  hard_exit:          true,
  output_logfilename: 'binance_daemon.log'
}

Daemons.run('./lib/scripts/binance.rb', options)