#!/usr/bin/env ruby
require 'readline'
$address = []
$openedfiles = []


def infothing
  file  = File.open("fat32.img",'rb+')
  contents = file.read
  bytespersec = contents.unpack('@11 S_ ').pack('V').unpack('l')[0]
  secperclus = contents.unpack('@13 C ').pack('V').unpack('l')[0]
  rsvdseccnt = contents.unpack('@14 S_ ').pack('V').unpack('l')[0]
  numFATS = contents.unpack('@16 C').pack('V').unpack('l')[0]
  fATSz32 = contents.unpack('@36 S_').pack('V').unpack('l')[0]
  rootClus = contents.unpack('@44 S_').pack('V').unpack('l')[0]
  rootEntCnt = contents.unpack('@17 L').pack('V').unpack('l')[0]

  @bytespersec = bytespersec
  @secperclus = secperclus
  @rsvdseccnt = rsvdseccnt
  @numFATS = numFATS
  @fATSz32 = fATSz32
  @rootClus = rootClus
  @rootEntCnt = rootEntCnt #should be zero

  return bytespersec, secperclus, rsvdseccnt, numFATS, fATSz32, rootClus, rootEntCnt
end

#globals for use anywher

# $bytespersec = @bytespersec
# $secperclus = @secperclus
# $rsvdseccnt = @rsvdseccnt
# $numFATS = @numFATS
# $fATSz32 = @fATSz32
# $rootClus = @rootClus
# $rootEntCnt = @rootEntCnt





def currentDir
  firstDatasec = (@rsvdseccnt + (@numFATS * @fATSz32)) # + rootDirSec(which is 0)
  #firstDatasec   2050

  directoryAdd = (firstDatasec * @bytespersec)
  #should be 2050 * 512
  #p directoryAdd
  $current = directoryAdd
end


def getDir
  file  = File.open("fat32.img",'rb')
  nextdir = $current + @rsvdseccnt
  # for each
  if file.read(nextdir).unpack('@11 V') == '\x0F'
    nextdir = nextdir + @rsvdseccnt
  end
  @nextdir = nextdir
  #p nextdir
  $current = nextdir
end



def directory
  file  = File.open("fat32.img",'rb')
  file.seek($current, IO::SEEK_SET)

  name = file.readlines('fat32.img')

  newname = name[0].gsub(/\s.*/, '')

  $address.push(newname)
end


def getSize
  file  = File.open("fat32.img",'rb')
  contents = file.seek(-1, IO::SEEK_END)
  p contents
end


# Have it take in the CurrentDirAddr.  The first thing ls should do is
# seek to that address.  Now you are sitting at the beginning of some
# directory.
#
# Take a look at the FAT32 Spec starting at the middle of page 22.  We
# need to figure out how to *read* the directories so that we can print
# the name of the files and directories inside.
#
# Each directory is broken up into 32-byte chunks of information called
# directory entries.  Each directory entry has an attribute telling you
# what is there -- a file?  A directory?  A volume ID?  Page 23 will show
# you a table of how directory entries are laid out.  (If the attribute is
# a long name, just skip that entry and move onto the next 32-byte
# entry.)  If the attributes tells you the entry holds a file or
# directory, print the short name to the user and move onto the next
# directory entry.





def openstuff
  filename = [(print 'file:'), gets.rstrip.upcase][1]
  if $address.include?(filename)
    $openedfiles.push(filename)
    puts "the #{filename} is now open"
  else
    puts "does not exist"
  end
end

def closedstuff
  filename = [(print 'file:'), gets.rstrip.upcase][1]
  if $openedfiles.include?(filename)
    $openedfiles.delete(filename)
    puts "the #{filename} is now closed"
  else
    puts "does not exist"
  end
end

def readstuff
  filename = [(print 'file:'), gets.rstrip.upcase][1]
  if $openedfiles.include?(filename)
    puts "reading #{filename}"
  else
    puts "that file is not open"
  end
end





LIST = [
  'info','cd', 'ls', 'open', 'close','read', 'exit', 'x'
].sort

comp = proc { |s| LIST.grep(/^#{Regexp.escape(s)}/) }

Readline.completion_append_character = " "
Readline.completion_proc = comp

stty_save = `stty -g`.chomp
trap('INT') { system('stty', stty_save); exit }


  while choice = Readline.readline("/] ", true)
  #i = 0

  #until i == 1 do
    #choice = [(print '/]'), gets.rstrip][1]

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

    when 'size'
      getSize

    when 'cd'
      puts "this should change directory"

    when 'ls'
      infothing
      puts "this should show all directories"
      currentDir
      count = 0
      file = File.open('fat32.img','r')
      until count == 15
        directory
        getDir
        count += 1
      end
      p $address

    when 'open'
      infothing
      currentDir
      directory
      getDir
      openstuff

    when 'close'
      closedstuff

    when 'read'
      readstuff

    when 'exit'
      puts "Shutting down now"
      exit

    when 'x'
      puts "Shutting down now"
      exit


    else
      puts "thats not a usable arg"
    end
  end
