#!/usr/bin/env ruby

require 'audite'
require 'ruby-progressbar'


player = Audite.new

player.load(ARGV.first)
bar = ProgressBar.create( :format => '%a %bᗧ%i %p%% %t',
                          :progress_mark  => ' ',
                          :remainder_mark => '･',
                          :title => "我",
                          :total => player.length_in_seconds)

player.events.on(:position_change) do |pos|
  bar.progress = pos
end

player.events.on(:complete) do
  if !player.active
    player.close
  end
end

player.start_stream

player.thread.join
