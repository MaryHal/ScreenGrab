#!/usr/bin/ruby -w

require 'optparse'

# Parse command line options
options = {}
optparse = OptionParser.new do|opts|
    #opts.banner = ""

    options[:output] = "./test.mkv"
    opts.on( '-o', '--output file', 'Output File' ) do|output|
        options[:output] = output
    end

    options[:fps] = 30
    opts.on( '-r', '--rate fps', Integer, 'Frames Per Second' ) do|fps|
        options[:fps] = fps
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end

optparse.parse!

vcodecs = Hash.new
vcodecs[:h264_fast] = []

acodecs = Hash.new
acodecs[:flac] = []

def captureCommand(exe)
    command = [exe,
               # Audio Settings
               "-f",      "alsa",
               "-ac",     "2",       # Two audio channels
               "-i",      "hw:0,0",
               "-acodec", "flac",

               # Video Settings
               "-f",      "x11grab",
               "-r",      "30",      # Frame Rate
               "-i",      ":0.0",
               "-vcodec",  "libtheora",
               "-b:v",     "4000k",

               # Output file
               "test.mkv"
    ]
    return command.join(' ')
end

# Dependency Checking
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end

def checkDependencies()
    if which("xdpyinfo").nil?
        raise "xdpyinfo is required to run this script."
    end

    if !which("ffmpeg").nil?
        return "ffmpeg"
    elsif !which("avconv").nil?
        return "avconv"
    end
    raise "ffmpeg or avconv required to run this script."
end

# Main script
if __FILE__ == $0
    puts options

    exe = checkDependencies
    command = captureCommand(exe)
    `#{command}`
end

