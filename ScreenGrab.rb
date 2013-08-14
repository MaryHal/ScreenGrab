#!/usr/bin/ruby -w

require 'optparse'

options = {}

# Parse command line options
optparse = OptionParser.new do|opts|
    #opts.banner = "Usage: passgen [options] [length of passwords to generate]"

    options[:output] = "./test.mkv"
    opts.on( '-o', '--output file', 'Output File' ) do|output|
        options[:output] = output
    end

    options[:fps] = "./test.mkv"
    opts.on( '-r', '--rate fps', 'Frames Per Second' ) do|fps|
        options[:fps] = fps
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
    end
end

def capture(options)
    `ffmpeg -f x11grab -r #{options[:fps]} -i :0.0 -f alsa -i hw:0,0 -acodec flac -vcodec ffvhuff #{options[:output]}`
end

optparse.parse!

# Main script
if __FILE__ == $0
    puts options
    capture(options)
end

