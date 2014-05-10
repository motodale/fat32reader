#!/usr/bin/env ruby



def infothing
  file  = File.open("fat32.img",'rb+')
  contents = file.read
  bytespersec = contents.unpack('@11 S_ ')[0]
  secperclus = contents.unpack('@13 C ')[0]
  rsvdseccnt = contents.unpack('@14 S_ ')[0]
  numFATS = contents.unpack('@16 C')[0]
  fATSz32 = contents.unpack('@36 S_')[0]
  rootClus = contents.unpack('@44 S_')[0]
  rootEntCnt = contents.unpack('@17 L')[0]

  @bytespersec = bytespersec
  @secperclus = secperclus
  @rsvdseccnt = rsvdseccnt
  @numFATS = numFATS
  @fATSz32 = fATSz32
  @rootClus = rootClus
  @rootEntCnt = rootEntCnt #should be zero

  return bytespersec, secperclus, rsvdseccnt, numFATS, fATSz32, rootClus, rootEntCnt
end

def currentDir
  firstDatasec = (@rsvdseccnt + (@numFATS * @fATSz32)) # + rootDirSec(which is 0)
  #firstDatasec   2050

  directoryAdd = (firstDatasec * @bytespersec)
  #should be 2050 * 512
  p directoryAdd
  @current = directoryAdd

end


$address = []

def directory
  file  = File.open("fat32.img",'rb')
  contents = file.read(@current).unpack('@0 C11')
  name = contents.pack('C*')
  p name
  $address.push(name)
end


i = 0

until i == 1 do
  choice = [(print '/]'), gets.rstrip][1]

  case choice

  when 'info'
    bps,spc,rsc,nFS,f32,rcl,rec = infothing
    puts "Bytes per sector: #{bps}"
    puts "Sectors per cluster: #{spc}"
    puts "Reserved sectors: #{rsc}"
    puts "NumFATs: #{nFS}"
    puts "FATSz32: #{f32}"
    puts "Root Cluster: #{rcl}"
    puts "root ent count: #{rec}"

    # opening

  when 'size'
    puts "print size info"

  when 'cd'
    puts "this should change directory"

  when 'ls'
    infothing
    puts "this should show all directories"
    currentDir
    directory
  when 'open'
    # $name = [(print '::'), gets.rstrip][1]
    # openfile

  when 'close'
    puts "closing file"

  when 'read'
    puts "reading file"

  when 'exit'
    puts "Shutting down now"
   i = 1

 when 'x'
    puts "Shutting down now"
   i = 1


  else
    puts "thats not a usable arg"
  end
end
