#!/usr/bin/env ruby

def infothing
  file  = File.open("fat32.img",'r')
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

#FirstDataSector = BPB_ResvdSecCnt + (BPB_NumFATs * FATSz) + RootDirSectors

# def datasec
#   rootDirSec = [((@rootEntCnt * (32) + (@bytespersec - 1)))/ @bytespersec]
#   p rootDirSec
#   firstDatasec = (@rsvdseccnt + (@numFATS * @fATSz32) + rootDirSec)
#   p firstDatasec
#   firstSector = (((rootDirSec - 2) * @secperclus) + firstDatasec)
#   p firstSector
#   @sector = firstSector
#   return firstSector
# end


$filearray = []
def openfile
  if $filearray.include? $name
    p $filearray
  else
    $filearray.push($name)
  end
end


i = 0

until i == 1 do
  choice = [(print '/]'), gets.rstrip][1]
  # datasec
  case choice

  when 'info'
    bps,spc,rsc,nFS,f32,rcl,rec = infothing
    puts "Bytes per sector: #{bps}"
    puts "Sectors per cluster: #{spc}"
    puts "Reserved sectors: #{rsc}"
    puts "NumFATs: #{nFS} "
    puts "FATSz32: #{f32}"
    puts "Root Cluster: #{rcl}"
    puts "root ent count: #{rec} "

  when 'size'
    puts "print size info"

  when 'cd'
    puts "this should change directory"

  when 'ls'
    puts "this should show all directories"

  when 'open'
    #$name = [(print '::'), gets.rstrip][1]
    #openfile



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
