#!/bin/bash

#############################
# Lang Live-Stream recorder
# Author: wieTW
# Website: blog.wie.tw
# email: yep2858@gmail.com
# Last version: 0.3.3
# Last modify: 2020.07.14
#############################

#============================
#  Global variable
#============================
id=$1
delayLoopTime=$2 # second
untilEndTime=$3  # minute
recordFormat=$4
useCurl=$5

#recordFormatList=("" "m4a" "mp3" "mp4")
recordFormatList[1]="m4a"
recordFormatList[2]="mp3"
recordFormatList[3]="audio"
recordFormatList[4]="mp4"

scriptStartTime=$(date '+%s')
scriptEndTime=0 # Here defined 0 is max value.

# Check runing system
unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=macOS ;;
CYGWIN*) machine=Cygwin ;;
MINGW*) machine=MinGw ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac
#echo ${machine}

clear
#============================
#  Get user input
#============================
#--------------
# id
#--------------
if [ -z $1 ]; then # If the parameters are not set, the user must to keyin.
    read -p "Enter LangLive ID [Default: 2014185]: " id_keyin
    #-t: countdown second
    if [ -z $id_keyin ]; then #-z: user does not enter anything, return true.
        id='2014185'
    else
        id=$id_keyin
    fi
fi

#--------------
# delayLoopTime
#--------------
if [ -z $2 ]; then
    read -p "Enter interval delay time(second) [Default: 10]: " -t 10 delay_keyin
    if [ -z $delay_keyin ]; then
        delayLoopTime=10
    else
        delayLoopTime=$delay_keyin
    fi
fi

#--------------
# untilEndTime
#--------------
if [ -z $3 ]; then
    read -p "Enter execution time(minute), 0=Unrestricted [Default: 180]: " until_keyin
    if [ -z $until_keyin ]; then
        untilEndTime=180
    else
        untilEndTime=$until_keyin
    fi
fi

if [ $untilEndTime -gt 0 ]; then
    untilEndTime_sec=$(expr $untilEndTime \* 60)
    scriptEndTime=$(expr $untilEndTime_sec + $scriptStartTime)

    case "${machine}" in
    Linux) echo 'Script stop time: ['$(date "+%Y-%m-%d_%H:%M:%S" --date=@$scriptEndTime)']' ;;
    macOS) echo 'Script stop time: ['$(date -r$scriptEndTime)']' ;;
    *) echo 'Never tested on this OS' ;;
    esac
else
    echo "Script stop time: [None]"
fi

#--------------
# recordFormat
#--------------
if [ -z $4 ]; then
    for ((i = 1; i <= ${#recordFormatList[@]}; i++)); do
        echo $i. ${recordFormatList[$i]}
    done

    read -p "Select record format [Default: audio]: " -t 10 format_keyin
    if [ -z $format_keyin ]; then
        recordFormat=${recordFormatList[3]}
    else
        recordFormat=${recordFormatList[$format_keyin]}
    fi
fi

#------------
# useCurl
#------------
if [ -z $5 ]; then
    read -p "Use curl update $id.json? [Y/n]: " idUpdate_keyin
    if [ -z $idUpdate_keyin ] || [ $idUpdate_keyin = 'Y' ]; then
        useCurl=true
    else
        useCurl=false
    fi
fi

echo ""

#============================
#  Confirm user input
#============================
curl -s https://langapi.lv-show.com/langweb/v1/room/liveinfo?room_id=$id >$id.json
nickname=$(cat $id.json | jq '.data.live_info.nickname' | sed 's/"//g')
AlbumCoverURL=$(cat $id.json | jq '.data.live_info.headimg' | sed 's/"//g')

#--------------------------------------------------------
# Change album cover image to recommend size 1600x1600
#--------------------------------------------------------
PictureSize=1600
# Source: http://blob.ufile.ucloud.com.cn/ddc3480ed6efbb9e87795932224d0bce.jpg?iopcmd=thumbnail&type=11&width=80&height=80
# Target: http://blob.ufile.ucloud.com.cn/ddc3480ed6efbb9e87795932224d0bce.jpg?iopcmd=thumbnail&type=11&width=1600&height=1600
AlbumCoverURL_ChangeSizeURL=''
AlbumCoverURL_SplitArray=(${AlbumCoverURL//&/ })

for eachValue in ${AlbumCoverURL_SplitArray[@]}; do
    KeyValue=(${eachValue//=/ })
    if [ ${KeyValue[0]} = 'width' ] || [ ${KeyValue[0]} = 'height' ]; then
        AlbumCoverURL_ChangeSizeURL=$AlbumCoverURL_ChangeSizeURL'&'${KeyValue[0]}'='$PictureSize
        #echo $AlbumCoverURL_ChangeSizeURL
    elif [ -z $AlbumCoverURL_ChangeSizeURL ]; then
        AlbumCoverURL_ChangeSizeURL=$AlbumCoverURL_ChangeSizeURL$eachValue
    else
        AlbumCoverURL_ChangeSizeURL=$AlbumCoverURL_ChangeSizeURL'&'$eachValue
        #echo $AlbumCoverURL_ChangeSizeURL
    fi
done
#echo Result-$AlbumCoverURL_ChangeSizeURL

#--------------------------------
# Check the number of parameters
#--------------------------------
if [ $# -lt 5 ]; then
    while [ true ]; do
        read -n 1 -p "Confirm record:[$recordFormat], roomID:[$id], nickname:[$nickname], cehck every [$delayLoopTime] seconds [Y/n]: " confirm_keyin
        echo ""
        if [ -z $confirm_keyin ] || [ $confirm_keyin = 'Y' ]; then
            break
        elif [ $confirm_keyin = 'n' ]; then
            exit
        fi
    done
fi

#============================
#  Start recording
#============================
while :; do
    if [ $useCurl = true ]; then
        curl -s https://langapi.lv-show.com/langweb/v1/room/liveinfo?room_id=$id >$id.json
    fi
    live_status=$(cat $id.json | jq '.data.live_info.live_status')
    currentTime=$(date +%Y-%m-%d_%H:%M:%S)

    if [ $live_status = 1 ]; then # When live_status is 1, it means that the anchor is online.
        liveurl=$(cat $id.json | jq '.data.live_info.liveurl_hls' | sed 's/"//g')
        nickname=$(cat $id.json | jq '.data.live_info.nickname' | sed 's/"//g') # 子涵

        #fileName=$nickname'-'$(date +%Y%m%d)'-浪LIVE直播' # 子涵-20200708-浪LIVE直播
        #if [ -f .$fileName ]; then
        # File exists
        #else
        # File does not exist
        #fi

        #----------------------------
        #  Recording streaming
        #----------------------------
        #fileName=$nickname'-'$(date +%Y%m%d-%H%M)'-浪LIVE直播' #$recordFormat # 子涵-20200708-1943-浪LIVE直播.m4a
        fileName=$id'-'$(date +%Y%m%d-%H%M) #$recordFormat # 子涵-20200708-1943-浪LIVE直播.m4a

        errorTimes=0
        while :; do
            echo '['$currentTime'] Start recording!!'
            youtube-dl $liveurl -o "$fileName.mp4"

            if [ $? = 0 ]; then
                echo '['$currentTime'] Finish recording!!'
                sleep 3

                break
            else
                errorTimes=$(expr $errorTimes + 1)
                echo '['$currentTime'] Error recording?! Try again ('$errorTimes')'
                echo 'Use other domain name: https://audio.lv-langlive.com/live/'$id'A.m3u8'
                liveurl='https://audio-tx.lv-play.com/live/'$id'A.m3u8'

                if [ $errorTimes -ge 3 ]; then
                    echo '['$currentTime'] Error '$errorTimes' times, Stop process'
                    exit
                fi
            fi
        done

        #----------------------------
        #  Convert media
        #  Add album cover image
        #----------------------------
        case $recordFormat in
        "m4a")
            ffmpeg -i "$fileName.mp4" -vn -acodec copy "$fileName.m4a"
            ;;
        "mp3")
            #ffmpeg -i videofile.mp4 -vn -acodec copy audiofile.mp3
            #ffmpeg -i video.mp4 -f mp3 -ab 48000 -vn music.mp3
            #ffmpeg -i video.mp4 -f mp3 -ab 192000 -vn music.mp3
            #ffmpeg -i "$fileName.mp4" -vn -acodec copy "$fileName.mp3"

            #ffmpeg -i input.wav -ac 1 -ab 64000 -ar 22050 output.mp3
            ffmpeg -i "$fileName.mp4" -f mp3 -ab 66000 -vn "$fileName.mp3"
            curl $AlbumCoverURL_ChangeSizeURL >$fileName.jpg
            lame --ti "$fileName.jpg" --ta "$nickname" --ty $(date '+%Y') "$fileName.mp3" # Cant setting  sampling frequency -s
            rm "$fileName.mp3"                                                            # remove original mp3 file
            mv "$fileName.mp3.mp3" "$fileName.mp3"                                        # modify new mp3 file name

            # -o '%(playlist_index)s. %(title)s.%(ext)s'
            #youtube-dl --extract-audio --audio-format $recordFormat $liveurl -o $fileName
            #youtube-dl -x --audio-format $recordFormat $liveurl -o $fileName
            ;;
        "audio")
            ffmpeg -i "$fileName.mp4" -vn -acodec copy "$fileName.m4a"

            ffmpeg -i "$fileName.mp4" -f mp3 -ab 66000 -vn "$fileName.mp3"
            curl $AlbumCoverURL_ChangeSizeURL >$fileName.jpg
            lame --ti "$fileName.jpg" --ta "$nickname" --ty $(date '+%Y') "$fileName.mp3" # Cant setting  sampling frequency -s
            rm "$fileName.mp3"                                                            # remove original mp3 file
            mv "$fileName.mp3.mp3" "$fileName.mp3"                                        # modify new mp3 file name
            ;;
        "mp4") ;;
        *)
            echo "Not ready to use this format: "$recordFormat
            exit
            ;;
        esac

        if [ $? = 0 ]; then
            echo '['$currentTime'] Finish convert to '$recordFormat'!!'
            sleep 3
        else
            echo '['$currentTime'] Error convert to '$recordFormat'?!'
            exit
        fi

        #----------------------------
        #  Upload to Google Drive
        #----------------------------
        gdriveDirName=$(gdrive list | grep "LangLive-$nickname" | awk '{print $1}') # Find Google Drive field name
        if [ -z $gdriveDirName ]; then
            echo "[GDrive] Create directory: LangLive-$nickname"
            gdrive mkdir "LangLive-$nickname" # 2020.7.11 Add "" :When the nickname has space, this command will be wrong
            sleep 1
            gdriveDirName=$(gdrive list | grep "LangLive-$nickname" | awk '{print $1}') # Find Google Drive field name
        fi

        # System langrage bug, can't find en another langrage of file.
        echo "[GDrive] Upload file: $fileName.$recordFormat to $gdriveDirName"
        if [ $recordFormat = 'audio' ]; then
            gdrive upload --parent $gdriveDirName $fileName.m4a
            gdrive upload --parent $gdriveDirName $fileName.mp3
        else
            gdrive upload --parent $gdriveDirName $fileName.$recordFormat
        fi
        #----------------------------------
        #  Check Google Drive upload file
        #----------------------------------
        if [ $recordFormat = 'audio' ]; then
            gdriveFileName=$(gdrive list | grep $fileName.m4a | awk '{print $1}')
            gdriveFileName2=$(gdrive list | grep $fileName.mp3 | awk '{print $1}')
            if [ -z $gdriveFileName ] || [ -z $gdriveFileName2 ]; then
                echo "[GDrive] Upload file check FAILE!! file: $gdriveFileName and $gdriveFileName2"
                exit
            else
                echo "[GDrive] Upload file check SUCCESS!! file: $gdriveFileName and $gdriveFileName2"
                rm $id*
            fi
        else
            gdriveFileName=$(gdrive list | grep $fileName.$recordFormat | awk '{print $1}')
            if [ -z $gdriveFileName ]; then
                echo "[GDrive] Upload file check FAILE!! file: $gdriveFileName"
                exit
            else
                echo "[GDrive] Upload file check SUCCESS!! file: $gdriveFileName"
                rm $id*
            fi
        fi
    else
        echo '['$currentTime'] ['$id' '$nickname'] Offline?! wait '$delayLoopTime' seconds ... '
    fi

    sleep $delayLoopTime # Wait few time
    if [ $scriptEndTime = 0 ]; then
        continue
    elif [ $(date '+%s') -gt $scriptEndTime ]; then
        echo '['$currentTime'] Task completed on time!!'
        break
    fi
done
