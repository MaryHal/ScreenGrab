#!/usr/bin/ruby -w

require 'optparse'

options = {}

# Parse command line options
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

def capture(options)
    `ffmpeg -f x11grab -r #{options[:fps]} -i :0.0 -f alsa -i hw:0,0 -acodec flac -vcodec ffvhuff #{options[:output]}`
end

# Main script
if __FILE__ == $0
    puts options
    capture(options)
end

