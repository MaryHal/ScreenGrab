#!/usr/bin/ruby -w

require 'optparse'

class ScriptOptions
    attr_reader :vdevices, :vcodecs, :adevices, :acodecs

    def initialize()
        @vdevices = Hash.new
        @vdevices["desktop"] = ["-f", "x11grab", "-i", ":0.0"]
        @vdevices["window"]  = ["-f", "x11grab", "-s", "", "-i", ":0.0"]
        @vdevices["webcam"]  = ["-f", "v4l2", "-i", "/dev/video0"]

        @vcodecs = Hash.new
        @vcodecs["raw"]        = ["-vcodec", "ffvhuff"]
        @vcodecs["h264_ultra"] = ["-vcodec", "libx264", "-preset", "ultrafast", "-qp", "0"]
        @vcodecs["h264_slow"]  = ["-vcodec", "libx264", "-preset", "veryslow", "-qp", "0"]
        @vcodecs["theora"]     = ["-vcodec", "libtheora", "-b:v", "4000k"]

        @adevices = Hash.new
        @adevices["alsa"] = ["-f", "alsa", "-i", "hw:0,0"]

        @acodecs = Hash.new
        @acodecs["flac"]   = ["-acodec", "flac"]
        @acodecs["vorbis"] = ["-acodec", "libvorbis"]
        @acodecs["mp3"]    = ["-acodec", "libmp3lame"]
    end

    def buildVideoOptions(device, codec, rate)
        if device == 'none'
            return []
        end

        videoCommand = @vdevices[device] +
                       @vcodecs[codec] +
                       [ '-r', rate.to_s ]

        if device == 'window'
            view = windowInfo()
            videoCommand[3] =  "#{view[2]}x#{view[3]}"
            videoCommand[5] += "+#{view[0]+view[4]},#{view[1]+view[4]}"
        end

        return videoCommand
    end

    def buildAudioOptions(device, codec)
        if device == 'none'
            return []
        end

        audioCommand = @adevices[device] +
                       @acodecs[codec]

        return audioCommand
    end

    def buildCommand(exe, vdevice, vcodec, rate, adevice, acodec, filename)
        return ([exe] + 
               buildVideoOptions(vdevice, vcodec, rate) +
               buildAudioOptions(adevice, acodec) +
               [filename]).join(' ')
    end

    # Parsing xwininfo
    def windowInfo
        x = 0
        y = 0
        w = 0
        h = 0
        b = 0

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
            elsif line.include? 'Border width:'
                b = line.match(regex).captures[0].to_i
            end
        end
        return [x, y, w, h, b]
    end
end

# Parse command line options
options = {}
optparse = OptionParser.new do|opts|
    #opts.banner = ""

    options[:output] = "./test.mkv"
    opts.on( '-o', '--output file', 'Output File' ) do|output|
        options[:output] = output
    end

    options[:acodec] = "vorbis"
    opts.on( '-a', '--acodec codec', 'Audio Codec' ) do|codec|
        options[:acodec] = codec
    end

    options[:adevice] = "none"
    opts.on( '-d', '--adevice device', 'Audio Device' ) do|device|
        options[:adevice] = device
    end

    options[:vcodec] = "theora"
    opts.on( '-v', '--vcodec codec', 'Video Codec' ) do|codec|
        options[:vcodec] = codec
    end

    options[:vdevice] = "desktop"
    opts.on( '-s', '--vdevice device', 'Video Device' ) do|device|
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

    script = ScriptOptions.new
    command = script.buildCommand(exe,
                                  options[:vdevice], options[:vcodec], options[:fps],
                                  options[:adevice], options[:acodec],
                                  options[:output])

    puts command
    `#{command}`
end

