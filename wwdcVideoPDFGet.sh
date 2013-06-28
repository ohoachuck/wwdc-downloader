#!/bin/sh

# Author: Olivier HO-A-CHUCK
# Date: June 15th 2013
# License: Do What You Want with it. But notice that this script come with no garanty and will not be maintained.


WWDC_DIRNAME="/Users/${USER}/Desktop/WWDC-2013"
TMP_DIR="/tmp/wwdc2013.tmp"


mkdir -p $TMP_DIR
#base=$(pwd)
ituneslogin=$1
itunespassword=$2
key=d4f7d769c2abecc664d0dadfed6a67f943442b5e9c87524d4587a95773750cea

cookies=(--cookies=on --keep-session-cookies)

action=$(wget -qO- 'https://daw.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/login?appIdKey='"${key}" | grep '\ action=' | awk '{ print $4 }' | cut -f2 -d"=" | sed -e "s/^.*\"\(.*\)\".*$/\1/") 
#echo "ACTION="${action}
wget -qO/dev/null "${cookies[@]}" --save-cookies=$TMP_DIR/cookies.txt "https://daw.apple.com${action}" --post-data='theAccountName='"${ituneslogin}"'&theAccountPW='"${itunespassword}"
wget -qO- --load-cookies=$TMP_DIR/cookies.txt \
     --save-cookies=$TMP_DIR/cookies.txt \
     --keep-session-cookies \
     "https://developer.apple.com/wwdc/videos/" --output-document=$TMP_DIR/video.html
          
cat ${TMP_DIR}/video.html | sed -e '/class="thumbnail-title/,/<div class="error">/!d' > $TMP_DIR/video-cleaned.html

if [ -f ${TMP_DIR}/titles.txt ] ; then
	rm ${TMP_DIR}/titles.txt
fi
cat ${TMP_DIR}/video-cleaned.html | while read line; do 
    echo $line | grep -o -E '<li class="thumbnail-title">(.*)</li><li class="thumbnail-id">(.*)</li>' | cut -d'>' -f2 | sed 's/\<\/li$//g' >> $TMP_DIR/titles.txt
done

while read line
do
    title_array+=("$line")
done < ${TMP_DIR}/titles.txt

echo "******* DOWNLOADING PDF FILES ********"

# PDF
mkdir -p ${WWDC_DIRNAME}/PDFs

# do the rm *.download only if files exist
FILES_LIST="$(ls ${WWDC_DIRNAME}/PDFs/*.download 2>/dev/null)"
if [ -z "$FILES_LIST" ]; then
	echo "I see this is the first time the script is being run! Cool :)"
	echo "All downloads will go to your Desktop/WWDC-2013 folder!"
else
	echo "Some download was aborted last time you ran this script."
	rm ${WWDC_DIRNAME}/PDFs/*.download	
	echo "Cleaning non fully downloaded files: OK." 
fi

i=0
cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}\.pdf\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
    if [ -f "${WWDC_DIRNAME}/PDFs/${title_array[$i]}.pdf" ]
	then
    	echo "${WWDC_DIRNAME}/PDFs/${title_array[$i]}.pdf already downloaded (nothing to do!)"
	else
	    echo "downloading PDF: $line" 
	    wget $line --output-document="${WWDC_DIRNAME}/PDFs/${title_array[$i]}.pdf.download"
		mv "${WWDC_DIRNAME}/PDFs/${title_array[$i]}.pdf.download" "${WWDC_DIRNAME}/PDFs/${title_array[$i]}.pdf"
	fi
    ((i+=1))
done

echo "******* DOWNLOADING SD VIDEOS ********"

# Videos SD
mkdir -p ${WWDC_DIRNAME}/SD-VIDEOs

# do the rm *.download only if files exist
FILES_LIST="$(ls ${WWDC_DIRNAME}/SD-VIDEOs/*.download 2>/dev/null)"
if [ -z "$FILES_LIST" ]; then
	echo "I see this is the first time you go for the videos themselves! Cool :)"
	echo "All downloads will go to your Desktop/WWDC-2013 folder!"
else
	echo "Some download was aborted last time you ran this script."
	rm ${WWDC_DIRNAME}/SD-VIDEOs/*.download	
	echo "Cleaning non fully downloaded files: OK." 
fi

rm ${WWDC_DIRNAME}/SD-VIDEOs/*.download
i=0
cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}-SD\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
    if [ -f "${WWDC_DIRNAME}/SD-VIDEOs/${title_array[$i]}-SD.mov" ]
	then
    	echo "${WWDC_DIRNAME}/SD-VIDEOs/${title_array[$i]}-SD.mov already downloaded (nothing to do!)"
	else
	    echo "downloading SD Video: $line" 
	    wget $line --output-document="${WWDC_DIRNAME}/SD-VIDEOs/${title_array[$i]}-SD.mov.download"
		mv "${WWDC_DIRNAME}/SD-VIDEOs/${title_array[$i]}-SD.mov.download" "${WWDC_DIRNAME}/SD-VIDEOs/${title_array[$i]}-SD.mov"
	fi
    ((i+=1))
done

rm -Rf ${TMP_DIR}

