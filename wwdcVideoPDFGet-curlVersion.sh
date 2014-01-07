#!/bin/sh

# Author: Olivier HO-A-CHUCK
# Date: June 27th 2013
# License: Do what you want with it. But notice that this script comes with no warranty and will not be maintained.
# Usage: wwdcVideoGet-curlVersion.sh <Apple-dev-account-login>
# To get 2013 tech-talks content: ./wwdcVideoGet-curlVersion.sh -e tech-talks <Apple-dev-account-login>
#
# TODO: 
#	- make 2012 videos download possible
#	- dynamically set WWDC_DIRNAME according to download year
#	- wrong password does not give proper error message!
#	- display some statistics: total time of download (+ begin and end), total downloaded size of content

VERSION="1.3"
DEFAULT_FORMAT="SD"
DEFAULT_YEAR="2013"
DEFAULT_EVENT="wwdc"
SELECTIVE_SESSION_MODE=false
VERBOSE=false
TMP_DIR="/tmp/wwdc2013.tmp"
WWDC_DIRNAME="/Users/${USER}/Documents/WWDC-2013"
VIDEO_URL_WWDC="https://developer.apple.com/wwdc/videos/"
VIDEO_URL_TECHTALK="https://developer.apple.com/tech-talks/videos/"


doGetWWDC2013 () {

	ituneslogin=$1
	itunespassword=$2
	FORMAT=$3
	
	if [ ${VERBOSE} == true ];
	then
	  echo "Sessions to be downloaded: ${SESSION_WANTED}"
	  echo "Output directory: ${WWDC_DIRNAME}"
	fi

	mkdir -p $TMP_DIR
	# Dynamically get the key value as this can change (it did change for instance when Apple had to turn down their developer Portal for a week)
	if [ ${VERBOSE} == true ];
	then
		echo "Getting appIDKey..."
	fi
	key=$(curl -s -L https://developer.apple.com/iphone | grep 'login?&appIdKey=' | sed -e 's/\(.*login?&appIdKey=\)\(.*\)\(&.*\)/\2/' | awk 'NR==1 {print $1}')
	if [ ${VERBOSE} == true ];
	then
		echo "appIDKey: ${key}"	
	fi
	cookies=(--cookies=on --keep-session-cookies)

	action=$(curl -s 'https://daw.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/login?appIdKey='"${key}" | grep '\ action=' | awk '{ print $4 }' | cut -f2 -d"=" | sed -e "s/^.*\"\(.*\)\".*$/\1/") 

	curl -s --cookie-jar $TMP_DIR/cookies.txt "https://daw.apple.com${action}" -d theAccountName="${ituneslogin}" -d theAccountPW="${itunespassword}" > /dev/null 

	curl  -s --cookie $TMP_DIR/cookies.txt \
		 --cookie-jar $TMP_DIR/cookies.txt \
		 ${VIDEO_URL} > $TMP_DIR/video.html
		 		  
	cat ${TMP_DIR}/video.html | sed -e '/class="thumbnail-title/,/<div class="error">/!d' > $TMP_DIR/video-cleaned.html

	if [ -f ${TMP_DIR}/titles.txt ] ; then
		rm ${TMP_DIR}/titles.txt
	fi
	cat ${TMP_DIR}/video-cleaned.html | while read line; do 
		echo $line | grep -o -E '<li class="thumbnail-title">(.*)</li><li class="thumbnail-(id|play)">(.*)</li>' | cut -d'>' -f2 | sed 's/\<\/li$//g' >> $TMP_DIR/titles.txt
	done

	while read line
	do
		title_array+=("$line")
	done < ${TMP_DIR}/titles.txt

	echo "******* DOWNLOADING PDF FILES ********"

	# PDF
	mkdir -p "${WWDC_DIRNAME}"/PDFs

	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/PDFs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		#echo "All downloads will go to your Documents/WWDC-2013 folder!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/PDFs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi

	i=0
	cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}\.pdf\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
		session_number=`echo $line | grep -o -E '/[0-9]+.pdf' | grep -o -E [0-9]+`
		if [ ${SELECTIVE_SESSION_MODE} == true ];
		then
			if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
			then
				dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$i]}.pdf"
				if [ -f "${dest_path}" ]
				then
					echo "${dest_path} already downloaded (nothing to do!)"
				else
					echo "downloading PDF for session ${session_number}: $line" 

					curl $line > "${dest_path}.download"
		
					mv "${dest_path}.download" "${dest_path}"
				fi
			fi
		else
			dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$i]}.pdf"
			if [ -f "${dest_path}" ]
			then
				echo "${dest_path} already downloaded (nothing to do!)"
			else
				echo "downloading PDF for session ${session_number}: $line" 

				curl $line > "${dest_path}.download"
	
				mv "${dest_path}.download" "${dest_path}"
			fi
		fi
		((i+=1))
	done

	echo "******* DOWNLOADING ${FORMAT} VIDEOS ********"

	# Videos ${FORMAT}
	mkdir -p "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs

	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		#echo "All downloads will go to your Desktop/WWDC-2013 folder!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi

	i=0
	# TODO: This extra if then elif test should not be there (duplicated code), but I don't know so far how to use $FORMAT in the grep -o -E regex! :(
	# Word boundaries should help like \<$FORMAT\>, but I'm not sure this is compliant with all grep versions. And I don't want to use egrep (non standard).
	# I know even with if then, this can be improved in terms or number of code lines. But hey, I'm a Marketing guys. Sorry for the very quick and dirty bit :(((
	if [ ${FORMAT} = "HD" ];
	then
		# TODO: / WARNING (for possible future doGetXXX2013 function merge): note that devstreaming url does use hard coded "wwdc" in it, were tech-talks function url is "techtalks" (whithout dash)
		cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}-HD\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
			session_number=`echo $line | grep -o -E '/[0-9]+-HD.mov' | grep -o -E [0-9]+`
			if [ ${SELECTIVE_SESSION_MODE} == true ];
			then
				if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
				then
					dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
					if [ -f "${dest_path}" ]
					then
						echo "${dest_path} already downloaded (nothing to do!)"
					else
						echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

						curl $line > "${dest_path}.download"

						mv "${dest_path}.download" "${dest_path}"
					fi
				fi
			else
				dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
				if [ -f "${dest_path}" ]
				then
					echo "${dest_path} already downloaded (nothing to do!)"
				else
					echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

					curl $line > "${dest_path}.download"

					mv "${dest_path}.download" "${dest_path}"
				fi
			fi
			((i+=1))
		done
	elif [ ${FORMAT} = "SD" ];
	then
		cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/2013/[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}-SD\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
			session_number=`echo $line | grep -o -E '/[0-9]+-SD.mov' | grep -o -E [0-9]+`
			if [ ${SELECTIVE_SESSION_MODE} == true ];
			then
				if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
				then
					dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
					if [ -f "${dest_path}" ]
					then
						echo "${dest_path} already downloaded (nothing to do!)"
					else
						echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

						curl $line > "${dest_path}.download"

						mv "${dest_path}.download" "${dest_path}"
					fi
				fi
			else
				dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
				if [ -f "${dest_path}" ]
				then
					echo "${dest_path} already downloaded (nothing to do!)"
				else
					echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

					curl $line > "${dest_path}.download"

					mv "${dest_path}.download" "${dest_path}"
				fi
			fi
			((i+=1))
		done
	fi

	rm -Rf ${TMP_DIR}
}

#**************************************************************************************#
#                                   TECH TALK                                          #
#**************************************************************************************#
doGetTT2013 () {

	ituneslogin=$1
	itunespassword=$2
	FORMAT=$3
	
	if [ ${VERBOSE} == true ];
	then
	  echo "Sessions to be downloaded: ${SESSION_WANTED}"
	  echo "Output directory: ${WWDC_DIRNAME}"
	fi

	mkdir -p $TMP_DIR
	# Dynamically get the key value as this can change (it did change for instance when Apple had to turn down their developer Portal for a week)
	if [ ${VERBOSE} == true ];
	then
		echo "Getting appIDKey..."
	fi
	key=$(curl -s -L https://developer.apple.com/iphone | grep 'login?&appIdKey=' | sed -e 's/\(.*login?&appIdKey=\)\(.*\)\(&.*\)/\2/' | awk 'NR==1 {print $1}')
	if [ ${VERBOSE} == true ];
	then
		echo "appIDKey: ${key}"	
	fi
	cookies=(--cookies=on --keep-session-cookies)

	action=$(curl -s 'https://daw.apple.com/cgi-bin/WebObjects/DSAuthWeb.woa/wa/login?appIdKey='"${key}" | grep '\ action=' | awk '{ print $4 }' | cut -f2 -d"=" | sed -e "s/^.*\"\(.*\)\".*$/\1/") 

	curl -s --cookie-jar $TMP_DIR/cookies.txt "https://daw.apple.com${action}" -d theAccountName="${ituneslogin}" -d theAccountPW="${itunespassword}" > /dev/null 

	curl  -s --cookie $TMP_DIR/cookies.txt \
		 --cookie-jar $TMP_DIR/cookies.txt \
		 ${VIDEO_URL} > $TMP_DIR/video.html
		  
	cat ${TMP_DIR}/video.html | sed -e '/class="thumbnail-title/,/<div class="error">/!d' > $TMP_DIR/video-cleaned.html

	if [ -f ${TMP_DIR}/titles.txt ] ; then
		rm ${TMP_DIR}/titles.txt
	fi
	cat ${TMP_DIR}/video-cleaned.html | while read line; do 
		echo $line | grep -o -E '<li class="thumbnail-title">(.*)</li><li class="thumbnail-(id|play)">(.*)</li>' | cut -d'>' -f2 | sed 's/\<\/li$//g' >> $TMP_DIR/titles.txt
	done

	while read line
	do
		title_array+=("$line")
	done < ${TMP_DIR}/titles.txt

	echo "******* DOWNLOADING PDF FILES ********"

	# PDF
	mkdir -p "${WWDC_DIRNAME}"/PDFs

	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/PDFs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		#echo "All downloads will go to your Desktop/WWDC-2013 folder!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/PDFs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi

	i=0
	cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/techtalks\/2013/[0-9a-zA-Z_\-]*\/[0-9a-zA-Z_\-]*\.pdf\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
		session_number=`echo $line | grep -o -E '/[0-9]+_' | grep -o -E [0-9]+`
		if [ ${SELECTIVE_SESSION_MODE} == true ];
		then
			if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
			then
				dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$i]}.pdf"
				if [ -f "${dest_path}" ]
				then
					echo "${dest_path} already downloaded (nothing to do!)"
				else
					echo "downloading PDF for session ${session_number}: $line" 

					curl $line > "${dest_path}.download"
		
					mv "${dest_path}.download" "${dest_path}"
				fi
			fi
		else
			dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$i]}.pdf"
			if [ -f "${dest_path}" ]
			then
				echo "${dest_path} already downloaded (nothing to do!)"
			else
				echo "downloading PDF for session ${session_number}: $line" 

				curl $line > "${dest_path}.download"
	
				mv "${dest_path}.download" "${dest_path}"
			fi
		fi
		((i+=1))
	done

	echo "******* DOWNLOADING ${FORMAT} VIDEOS ********"

	# Videos ${FORMAT}
	mkdir -p "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs

	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		#echo "All downloads will go to your Desktop/WWDC-2013 folder!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi

	i=0
	# TODO: This extra if then elif test should not be there (duplicated code), but I don't know so far how to use $FORMAT in the grep -o -E regex! :(
	# Word boundaries should help like \<$FORMAT\>, but I'm not sure this is compliant with all grep versions. And I don't want to use egrep (non standard).
	# I know even with if then, this can be improved in terms or number of code lines. But hey, I'm a Marketing guys. Sorry for the very quick and dirty bit :(((
	if [ ${FORMAT} = "HD" ];
	then
		cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/techtalks\/2013/[0-9a-zA-Z_]*\/[0-9a-zA-Z_]*-hd\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
			session_number=`echo $line | grep -o -E '/[0-9]+_' | grep -o -E [0-9]+`
			if [ ${SELECTIVE_SESSION_MODE} == true ];
			then
				if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
				then
					dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
					if [ -f "${dest_path}" ]
					then
						echo "${dest_path} already downloaded (nothing to do!)"
					else
						echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

						# little trick to be consistant with upercase HD of wwdc file name types
						lineWithUperCaseHD="${line/-HD/-hd}" 
						curl $lineWithUperCaseHD > "${dest_path}.download"

						mv "${dest_path}.download" "${dest_path}"
					fi
				fi
			else
				dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
				if [ -f "${dest_path}" ]
				then
					echo "${dest_path} already downloaded (nothing to do!)"
				else
					echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

					# little trick to be consistant with upercase HD of wwdc file name types
					lineWithUperCaseHD="${line/-HD/-hd}" 
					curl $lineWithUperCaseHD > "${dest_path}.download"

					mv "${dest_path}.download" "${dest_path}"
				fi
			fi
			((i+=1))
		done
	elif [ ${FORMAT} = "SD" ];
	then
		cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/techtalks\/2013/[0-9a-zA-Z_]*\/[0-9a-zA-Z_]*-sd\.mov\?dl=1+)"' | cut -d'"' -f2 | while read line; do 
			session_number=`echo $line | grep -o -E '/[0-9]+_' | grep -o -E [0-9]+`
			if [ ${SELECTIVE_SESSION_MODE} == true ];
			then
				if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
				then
					dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
					if [ -f "${dest_path}" ]
					then
						echo "${dest_path} already downloaded (nothing to do!)"
					else
						echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

						# little trick to be consistant with upercase SD of wwdc file name types
						lineWithUperCaseSD="${line/-SD/-sd}"
						curl $lineWithUperCaseSD > "${dest_path}.download"

						mv "${dest_path}.download" "${dest_path}"
					fi
				fi
			else
				dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$i]}-${FORMAT}.mov"
				if [ -f "${dest_path}" ]
				then
					echo "${dest_path} already downloaded (nothing to do!)"
				else
					echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

					# little trick to be consistant with upercase SD of wwdc file name types
					lineWithUperCaseSD="${line/-SD/-sd}" 
					curl $lineWithUperCaseSD > "${dest_path}.download"

					mv "${dest_path}.download" "${dest_path}"
				fi
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
#######                      		   MAIN 									##########
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
EVENT=${DEFAULT_EVENT}

while getopts ":hy:f:s:vo:e:" opt; do
  case $opt in
    h)
	  	echo "WWDC Videos and PDFs downloader (version ${VERSION})" >&2
      	echo ""
	  	echo "Usage: 	`basename $0` [options] <Apple dev login>"
	  	echo "Options:"
      	echo "	-y <year>: select year (ex: -y 2012). Default year is 2013" >&2
      	echo "		Possible values for year: 2012, 2013, all" >&2
      	echo "		Warning: year 2012 videos download is not yet available" >&2
      	echo "	-e <event>: select event type between \"wwdc\" and \"tech-talks\"" >&2
      	echo "		default value is \"wwdc\"" >&2
      	echo "	-f <format>: select video format type (SD or HD). Default video format is SD" >&2
      	echo "	-s <comma separated session numbers>: select which sessions you want to download" >&2
      	echo "	-v : verbose mode" >&2
      	echo "	-o <output path>: path where to download content (default is /Users/${USER}/Documents/WWDC-2013)" >&2
      	echo ""  >&2
      	echo "Examples:"  >&2
      	echo "	- Download all PDFs and SD videos for wwdc 2013:"  >&2
      	echo "  		`basename $0` john.doe@me.com"  >&2
      	echo "	- Download all PDFs and SD videos for tech-talks 2013:"  >&2
      	echo "  		`basename $0` -e tech-talks john.doe@me.com"  >&2
      	echo "	- Download all PDFs and HD videos for wwdc 2013:"  >&2
      	echo "  		`basename $0` -f HD john.doe@me.com"  >&2
      	echo "	- Download only session 201, 400 and 401 with SD videos for wwdc 2013:"  >&2
      	echo "  		`basename $0` -s 201,400,401 john.doe@me.com"  >&2
      	echo "	- Download only session 201 and 400 with HD video for wwdc 2013:"  >&2
      	echo "  		`basename $0` -s 201,400 -f HD john.doe@me.com"  >&2
      	echo "	- Download all PDFs and HD videos for wwdc 2013 in /Users/oho/Documents/WWDC-SESSIONS using verbose mode:"  >&2
      	echo "  		`basename $0` -v -f HD -o /Users/oho/Documents/WWDC-SESSIONS john.doe@me.com"  >&2
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
    s)
      	if [ $OPTARG > 0 ];
      	then
	    	SESSION_WANTED=$OPTARG
	    	SELECTIVE_SESSION_MODE=true
	  	else
	  		echo "Session number does not look good!"
	  	fi
      	;;
    v)
      	echo "Verbose mode on"
      	VERBOSE=true
      	;;
    o)
	  	WWDC_DIRNAME=${OPTARG}
	  	;;
	e)
      	if [ $OPTARG = "tech-talks" ] || [ $OPTARG = "wwdc" ] ;
      	then
	  		EVENT=$OPTARG
	  	else
	  		echo "Unknown event type. Using default (${EVENT})!"
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
	read -r -s -p Password: itunespassword ; echo
	doGet2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	;;
"2013")
	read -r -s -p Password: itunespassword ; echo
	if [ ${EVENT} == "wwdc" ];
	then
		VIDEO_URL=${VIDEO_URL_WWDC}
		doGetWWDC2013 ${ituneslogin} ${itunespassword} ${FORMAT}
	elif [ ${EVENT} == "tech-talks" ];
	then
		VIDEO_URL=${VIDEO_URL_TECHTALK}
		doGetTT2013 ${ituneslogin} ${itunespassword} ${FORMAT}
	fi
	;;
"all" | "ALL")
	read -r -s -p Password: itunespassword ; echo
	doGet2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	doGet2013 ${ituneslogin} ${itunespassword} ${FORMAT}
	;;
*)
	echo "Sorry: can't process requested year. Please choose between \"2012\", \"2013\" or \"all\"."
	;;
esac

exit 0;
