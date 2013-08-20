#!/usr/bin/ruby -w

require 'optparse'

vdevices = Hash.new
vdevices["none"] = []
vdevices["desktop"] = ["-f", "x11grab", "-i", ":0.0"]
vdevices["webcam"]  = ["-f", "v4l2", "-i", "/dev/video0"]

vcodecs = Hash.new
vcodecs["raw"]        = ["-vcodec", "ffvhuff"]
vcodecs["h264_ultra"] = ["-vcodec", "libx264", "-preset", "ultrafast", "-qp", "0"]
vcodecs["h264_slow"]  = ["-vcodec", "libx264", "-preset", "veryslow", "-qp", "0"]
vcodecs["theora"]     = ["-vcodec", "libtheora", "-b:v", "4000k"]

adevices = Hash.new
adevices["none"] = []
adevices["alsa"] = ["-f", "alsa", "-i", "hw:0,0"]

acodecs = Hash.new
acodecs["flac"]   = ["-acodec", "flac"]
acodecs["vorbis"] = ["-acodec", "libvorbis"]
acodecs["mp3"]    = ["-acodec", "libmp3lame"]

# Parse command line options
options = {}
optparse = OptionParser.new do|opts|
    #opts.banner = ""

    options[:output] = "./test.mkv"
    opts.on( '-o', '--output file', 'Output File' ) do|output|
        options[:output] = output
    end

    options[:acodec] = "vorbis"
    acodecList = acodecs.keys.join(', ')
    opts.on( '-a', '--acodec codec', 'Audio Codec', acodecList ) do|codec|
        options[:acodec] = codec
    end

    options[:adevice] = "alsa"
    adeviceList = adevices.keys.join(', ')
    opts.on( '-d', '--adevice device', 'Audio Device', adeviceList ) do|device|
        options[:adevice] = device
    end

    options[:vcodec] = "theora"
    vcodecList = vcodecs.keys.join(', ')
    opts.on( '-v', '--vcodec codec', 'Video Codec', vcodecList ) do|codec|
        options[:vcodec] = codec
    end

    options[:vdevice] = "desktop"
    vdeviceList = vdevices.keys.join(', ')
    opts.on( '-s', '--vdevice device', 'Video Device', vdeviceList ) do|device|
        options[:vdevice] = device
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

# Parsing xwininfo
def windowInfo
    x = 0
    y = 0
    w = 0
    h = 0

    regex = /([0-9]+)/

    out = `xwininfo`
    out.each_line do |line|
        if line.include? 'Absolute upper-left X:'
            x = line.match(regex).captures[0].to_i
        elsif line.include? 'Absolute upper-left Y:'
            y = line.match(regex).captures[0].to_i
        elsif line.include? 'Width:'
            w = line.match(regex).captures[0].to_i
        elsif line.include? 'Height:'
            h = line.match(regex).captures[0].to_i
        end
    end
    puts x, y, w, h
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
    if which("xwininfo").nil?
        raise "xwininfo is required to run this script."
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

    command = [exe] + 
              adevices[options[:adevice]] +
              acodecs[options[:acodec]] +
              vdevices[options[:vdevice]] +
              vcodecs[options[:vcodec]] +
              [options[:output]]
    command = command.join(' ')
    `#{command}`
    #windowInfo
end

