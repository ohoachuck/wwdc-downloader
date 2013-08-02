#!/bin/sh

# Author: Olivier HO-A-CHUCK
# Date: June 27th 2013
# License: Do What You Want with it. But notice that this script come with no garanty and will not be maintained.
# usage: wwdcVideoGet-curlVersion.sh <Apple-dev-account-login>
# TODO: 
#	- wrong password does not give proper error message!
#	- key should be get dynamically - this already happened to be changed

VERSION="1.1"
DEFAULT_FORMAT="SD"
DEFAULT_YEAR="2013"
DEFAULT_KEY="891bd3417a7776362562d2197f89480a8547b108fd934911bcbea0110d07f757"


doGet2013 () {

	ituneslogin=$1
	itunespassword=$2
	FORMAT=$3

	WWDC_DIRNAME="/Users/${USER}/Desktop/WWDC-2013"
	TMP_DIR="/tmp/wwdc2013.tmp"
	mkdir -p $TMP_DIR

	key=${DEFAULT_KEY}
	
	cookies=(--cookies=on --keep-session-cookies)

	action=$(curl 'https://daw.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/login?appIdKey='"${key}" | grep '\ action=' | awk '{ print $4 }' | cut -f2 -d"=" | sed -e "s/^.*\"\(.*\)\".*$/\1/") 

	curl -s --cookie-jar $TMP_DIR/cookies.txt "https://daw.apple.com${action}" -d theAccountName="${ituneslogin}" -d theAccountPW="${itunespassword}" > /dev/null 

	curl  -s --cookie $TMP_DIR/cookies.txt \
		 --cookie-jar $TMP_DIR/cookies.txt \
		 "https://developer.apple.com/wwdc/videos/" > $TMP_DIR/video.html
		  
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
		session_number=`echo $line | grep -o -E '/[0-9]+.pdf' | grep -o -E [0-9]+`
		dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$i]}.pdf"
		if [ -f "${dest_path}" ]
		then
			echo "${dest_path} already downloaded (nothing to do!)"
		else
			echo "downloading PDF for session ${session_number}: $line" 

			curl $line > "${dest_path}.download"
		
			mv "${dest_path}.download" "${dest_path}"
		fi
		((i+=1))
	done

	echo "******* DOWNLOADING ${FORMAT} VIDEOS ********"

	# Videos ${FORMAT}
	mkdir -p ${WWDC_DIRNAME}/${FORMAT}-VIDEOs

	# do the rm *.download only if files exist
	FILES_LIST="$(ls ${WWDC_DIRNAME}/${FORMAT}-VIDEOs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		echo "I see this is the first time you go for the videos themselves! Cool :)"
		echo "All downloads will go to your Desktop/WWDC-2013 folder!"
	else
		echo "Some download was aborted last time you ran this script."
		rm ${WWDC_DIRNAME}/${FORMAT}-VIDEOs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi

	i=0
	# TODO: This extra if then elif test should not be there (duplicated code), but I don't know so far how to use $FORMAT in the grep -o -E regex! :(
	# Word boundaries should help like \<$FORMAT\>, but I'm not sure this is compliant with all grep versions. And I don't want to use egrep (non standard).
	# I know even with if then, this can be improved in terms or number of code lines. But hey, I'm a Marketing guys. Sorry for the very quick and dirty bit :(((
	if [ ${FORMAT} = "HD" ];
	then
		cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}-HD\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
			session_number=`echo $line | grep -o -E '/[0-9]+-HD.mov' | grep -o -E [0-9]+`
			dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
			if [ -f "${dest_path}" ]
			then
				echo "${dest_path} already downloaded (nothing to do!)"
			else
				echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

				curl $line > "${dest_path}.download"

				mv "${dest_path}.download" "${dest_path}"
			fi
			((i+=1))
		done
	elif [ ${FORMAT} = "SD" ];
	then
		cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}-SD\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
			session_number=`echo $line | grep -o -E '/[0-9]+-SD.mov' | grep -o -E [0-9]+`
			dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
			if [ -f "${dest_path}" ]
			then
				echo "${dest_path} already downloaded (nothing to do!)"
			else
				echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

				curl $line > "${dest_path}.download"

				mv "${dest_path}.download" "${dest_path}"
			fi
			((i+=1))
		done
	fi

	rm -Rf ${TMP_DIR}
}

doGet2012 () {
	ituneslogin=$1
	itunespassword=$2
	FORMAT=$3
	echo "DEBUG: do 2012 (login=${ituneslogin} - password=${itunespassword} - format=${FORMAT})"
	WWDC_DIRNAME="/Users/${USER}/Desktop/WWDC-2012"
	TMP_DIR="/tmp/wwdc2012.tmp"
	mkdir -p $TMP_DIR

	echo ""
	echo "======> SORRY: 2012 VIDEO DOWNLOAD NOT YET IMPLEMENTED! <======="
	echo ""

	rm -Rf ${TMP_DIR}
}

##########################################################################################
#######                      		   MAINE 									##########
##########################################################################################

if [ $# -eq "0" ]
then
  echo "WWDC videos and PDFs downloader (version ${VERSION})" >&2
  echo "Usage: `basename $0` [options] <Apple dev login>"
  echo "Please use -h for more options"
  exit 1
fi

ituneslogin=${@: -1}
FORMAT=${DEFAULT_FORMAT}
YEAR=${DEFAULT_YEAR}

while getopts ":hy:f:" opt; do
  case $opt in
    h)
	  echo "WWDC Videos and PDFs downloader (version ${VERSION})" >&2
      echo ""
	  echo "Usage: 	`basename $0` [options] <Apple dev login>"
	  echo "Options:"
      echo "  -y <year>: select year (ex: -y 2012). Default year is 2013" >&2
      echo "	Possible values for year: 2012, 2013, all" >&2
      echo "	Warning: year 2012 videos download is not yet available" >&2
      echo "  -f <format>: select video format type (SD or HD). Default video format is SD" >&2
      echo ""  >&2
      echo "Example:"  >&2
      echo "  `basename $0` -y 2013 -f HD john.doe@me.com"  >&2
      echo ""
      exit 0;
      ;;
    y)
      if [ $OPTARG = "2012" ] || [ $OPTARG = "2013" ] || [ $OPTARG = "all" ];
      then
	  	YEAR=$OPTARG
	  else
	  	echo "Unknown specified year. Using ${YEAR}!"
	  fi
      ;;
    f)
      if [ $OPTARG = "SD" ] || [ $OPTARG = "HD" ];
      then
	      FORMAT=$OPTARG
	  else
	  	echo "Unknown specified format. Using ${FORMAT} video format!"
	  fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "For help, please use: $0 -h"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
  
case "${YEAR}" in
"2012")
	read -s -p Password: itunespassword ; echo
	doGet2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	;;
"2013")
	read -s -p Password: itunespassword ; echo
	doGet2013 ${ituneslogin} ${itunespassword} ${FORMAT}
	;;
"all" | "ALL")
	read -s -p Password: itunespassword ; echo
	doGet2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	doGet2013 ${ituneslogin} ${itunespassword} ${FORMAT}
	;;
*)
	echo "Sorry: can't process requested year. Please chose between \"2012\", \"2013\" or \"all\"."
	;;
esac

exit 0;
