#!/usr/bin/env ruby
require 'ruby-progressbar'
#bar = ProgressBar.create( :title => "hehe", :total => 10)
bar = ProgressBar.create( :title => "哈", :total => 10)

bar.increment
sleep 1
bar.increment
sleep 1
bar.increment
sleep 1
