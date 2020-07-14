# Lang Live- Stream recorder


[![Instagram URL](https://img.shields.io/twitter/url/https/www.instagram.com/yepwie?label=Follow&logo=instagram&style=social)](https://www.instagram.com/yepwie/) [![FaceBook URL](https://img.shields.io/twitter/url/https/www.facebook.com/william.yep?label=Like&logo=facebook&style=social)](https://www.facebook.com/william.yep)

------

[![GitHub All Releases](https://img.shields.io/github/downloads/wieTW/LangLive-Stream-recording/total?color=green)](https://github.com/wieTW/LangLive-Stream-recording/releases) 
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/wieTW/LangLive-Stream-recording?color=yellow&label=Latest%20Release)](https://github.com/wieTW/LangLive-Stream-recording/releases) 
[![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://paypal.me/wieTW)

<br/>

## Do you have this experience?
I like to listen to the broadcast of [Lang Live Radio](http://lang.live) . 
Sometimes I am not available at the moment and I can’t listen to the broadcast on time. 
Lang Live does not record the history video/audio (not currently available). 
You will miss an episode, so I wrote this tool to solve it.

<br/>


## What the tool can do for you？
Help you monitor the Lang Live radio.

When the host is online, the stream will be downloaded automatically, and then converted to mp3 or m4a music format.
Also upload to Google Drive. You can use link to share with your friends.

ID3 tags have been added to the mp3 format, now you can make an album! It's really exciting!

<br/>

## How to install?
This work on Linux/Unix OS

You need to download the package:
* jq
* youtube-dl
* ffmpeg
* curl
* lame
* gdrive

<br/>

## How to use?
bash Lang_StreamRecorder.sh
1. Enter the room id to record 
2. Enter interval delay time(second)
3. Enter execution time(minute), 0 = Unrestricted
4. Select record format: m4a, mp3, audio(m4a and mp3), mp4
5. Use curl to update room infomation?

<br/>

## Demo:
<img src="https://github.com/wieTW/LangLive-Stream-recorder/blob/master/Demo/ConsoleDemo.png?raw=true" class="center" width="1000"/>

<br/>
