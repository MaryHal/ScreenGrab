ScreenGrab
==========

Ruby script for desktop screen recording. Uses ffmpeg (or avconv). Even though ffmpeg is a really useful program, juggling all of the available switches and codecs quickly becomes unmanagable. This script translates simple options to ffmpeg.

Help
====

    Usage: ScreenGrab [options]
    -o, --output file                Output File
    -a, --acodec codec               Audio Codec
    -d, --adevice device             Audio Device
    -v, --vcodec codec               Video Codec
    -s, --vdevice device             Video Device
    -r, --rate fps                   Frames Per Second
    -b, --border                     If capturing a window, include the border?
    -h, --help                       Display this screen

Example
=======

Record desktop with default settings

    ScreenGrab -o test.mkv

Record window, high quality

    ScreenGrab -o test.mkv -a flac -d alsa -v h264_ultra -s window

Record from webcam

    ScreenGrab -o test.mkv -s webcam
