#!/usr/bin/env ruby

file = "test.txt"      # "fat32.img"


i = 0
until i == 1 do
  choice = [(print '/]'), gets.rstrip][1]
  case choice
  
  when 'info'
    puts "this is the info"
  when 'size'
    puts "print size info"
  when 'cd'
    puts "this should change directory"
  when 'ls'
    puts "this should show all directories"
  when 'open'
    puts "opening file"
  when 'close'
    puts "closing file"
  when 'read'
    puts "reading file"
  when 'exit'
    puts "Shutting down now"
   i = 1
  else
    puts "thats not a usable arg" 
  end

end
