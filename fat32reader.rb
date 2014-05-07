#!/usr/bin/env ruby

#file = "test.txt"      # "fat32.img"
def infothing
  file  = File.open("fat32.img",'r')
  contents = file.read
  bytespersec = contents.unpack('@11h2h2 s< l< q< ')
  secperclus = contents.unpack('@13h2 s< l< q< ')
  rsvdseccnt = contents.unpack('@14h2H2 s< l< q< ')
  numFATS = contents.unpack('@16h2 s< l< q<')
  fATSz32 = contents.unpack('@36h2 s< l< q<')
  
  return bytespersec, secperclus, rsvdseccnt, numFATS, fATSz32 
end

i = 0
until i == 1 do
  choice = [(print '/]'), gets.rstrip][1]
  case choice
  
  when 'info'
    bps,spc,rsc, nFS, f32 = infothing
    puts "Bytes per sector:"
    p bps
    puts "Sectors per cluster:"
    p spc
    puts "Reserved sectors:"
    p rsc
    puts "numfats is in here"
    p nFS
    puts "fATSz32 :"
    p f32
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
