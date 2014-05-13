#!/usr/bin/env ruby
require 'readline'
$address = []
$filelist = []
$openedfiles = []
$deletepile = []

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


  # Convert a given 4 byte integer from little-endian to the running
  # machine's native endianess.  The pack('V') operation takes the
  # given number and converts it to little-endian (which means that
  # if the machine is little endian, no conversion occurs).  On a
  # big-endian machine, the pack('V') will swap the bytes because
  # that's what it has to do to convert from big to little endian.
  # Since the number is already little endian, the swap has the
  # opposite effect (converting from little-endian to big-endian),
  # which is what we want. In both cases, the unpack('l') just
  # produces a signed integer from those bytes, in the machine's
  # native endianess.
end


def currentDir
  firstDatasec = (@rsvdseccnt + (@numFATS * @fATSz32)) # + rootDirSec(which is 0)


  directoryAdd = (firstDatasec * @bytespersec)
  #should be 2050 * 512

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
  newname = name[0]
  newname.each do |item|
    if item.to_s.match(/\\x00([a-zA-Z]){1}|\\x0F([a-zA-Z]){1}|(\.)/)
      newname.remove(item)
    else
      $address.push(item)
    end
  end

  p newname


end

#\\x00([a-zA-Z]){1}|\\x0F([a-zA-Z]){1}|(\.)

#$address.push(newname)


def getSize
  file  = File.open("fat32.img",'rb')

  contents = file.seek($current, IO::SEEK_SET)
  p contents
end


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





#http://www.ruby-doc.org/stdlib-2.1.1/libdoc/readline/rdoc/Readline.html
#the website used for the prompt with shell code, including memory of inputs

LIST = [
  'info' ,'cd' ,'ls' ,'size' ,'open' ,'close' ,'read' ,'exit' ,'x'
].sort

comp = proc { |s| LIST.grep(/^#{Regexp.escape(s)}/) }

Readline.completion_append_character = " "
Readline.completion_proc = comp

stty_save = `stty -g`.chomp
trap('INT') { system('stty', stty_save); exit }


  while choice = Readline.readline("/] ", true)

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
      infothing
      currentDir
      directory
      getDir
      getSize

    when 'cd'
      puts "this should change directory"

    when 'ls'
      infothing
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
