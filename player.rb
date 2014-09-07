#!/usr/bin/env ruby

require 'audite'
require 'ruby-progressbar'

def read_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if(c=="\e")
      extra_thread = Thread.new{
        c = c + STDIN.getc.chr
        c = c + STDIN.getc.chr
      }
      # wait just long enough for special keys to get swallowed
      extra_thread.join(0.00001)
      # kill thread so not-so-long special keys don't wait on getc
      extra_thread.kill
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end

def set_up_notifier(player)
  song_name = player.current_song_name.split('.').first
  system("terminal-notifier -title 🎵music -message #{song_name} -open http://github.com/ipmsteven" )
end

player = Audite.new

# load mp3 or directory

argv = File.expand_path(ARGV.first)

if Dir.exists?(argv)
  Dir.chdir(argv)
  mp3 = Dir.glob("*.mp3").map { |m| File.expand_path(m) }
  player.load(mp3)
  set_up_notifier player
elsif File.exist?(argv)
  player.load(argv)
  set_up_notifier player
else
  exit
end

bar = ProgressBar.create( :format => '%a %bᗧ%i %p%% %t',
                         :progress_mark  => ' ',
                         :remainder_mark => '･',
                         :title => player.current_song_name.split('.').first,
                         :total => player.length_in_seconds,
                         :length => 80)

player.events.on(:position_change) do |pos|
  bar.progress = pos
end

player.events.on(:complete) do
  if !player.active
    player.close
  end
end

player.start_stream


while c = read_char
  case c
  when " "
    player.toggle
  when "\e[A"
    #puts "UP ARROW"
    player.request_next_song
    song_name = player.current_song_name.split('.').first
    set_up_notifier player
    bar = ProgressBar.create( :format => '%a %bᗧ%i %p%% %t',
                             :progress_mark  => ' ',
                             :remainder_mark => '･',
                             :title => song_name,
                             :total => player.length_in_seconds,
                             :length => 80)
  when "\e[B"
    #puts "DOWN ARROW"
  when "\e[C"
    player.forward
  when "\e[D"
    player.rewind
  when "\e"
    exit
  end
end

player.thread.join


