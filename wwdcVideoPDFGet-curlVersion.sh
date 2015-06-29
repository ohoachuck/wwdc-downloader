#!/bin/sh

# Author: Olivier HO-A-CHUCK
# Date: June 27th 2013 (update June 12th 2015)
# Last update: 
#   - fixing duplicated download of source code (creating sim link instead)
#   - fixing pdf regression bug while using -f HD option. Thanx to Richard Watt (botsmack) for pointing this out
#   - fixing download of pdfs that does not exist in real life (Apple award and Keynote)
#   - fixing bug that get corrupted PDFs while using -f SD mode (default mode ;( ).
#   - adding PDFs download (wasn't there first then I forget !)
#   - fixed -L for years earlier than 2015
#   - "/Users/${USER}" changed for "${HOME}" for better compliancy with home directory differents than /Users
#   - Add wwdc 2015 video download (+ fixed issue with "Managing 3D Assets with Model I/O" session label).
#   - fixed issue with names like I/O
#   - adding download of ALL sample code (including those to grab on Apple documentation web site)
#   - adding check for network connectivity (bash does not handle connectivity error for you)
#   - fixing issue with name using comma in title (like ", part 1") - some might download them twice if using an early script - sorry ;(
# 
#
# License: Do what you want with it. But notice that this script comes with no warranty and will not be maintained.
# Usage: wwdcVideoGet-curlVersion.sh
# To get 2013 tech-talks content: ./wwdcVideoGet-curlVersion.sh -e tech-talks
#
# TODO: 
#	- make 2012 videos download possible (it's feasible but more painful than for 2013 and 2014, so time consuming...)
#	- wrong password does not give proper error message!
#	- display some statistics: total time of download (+ begin and end), total downloaded size of content
#   - check available disk space for possible alert (in particular if HD video are getting donwloaded with less than 60 GB of disk space)

VERSION="1.8.9"
DEFAULT_FORMAT="SD"
DEFAULT_YEAR="2015"
DEFAULT_EVENT="wwdc"
SELECTIVE_SESSION_MODE=false
LIST_MODE=false
VERBOSE=false
LOGIN=false
ITUNES_LOGIN=""
UNIQID=`uuidgen`
TMP_DIR="/tmp/wwdc-session-$UNIQID.tmp"
VIDEO_URL_WWDC="https://developer.apple.com/videos/wwdc"
VIDEO_URL_TECHTALK="https://developer.apple.com/tech-talks/videos/"
SAMPLE_CODE_ROOT_URL="https://developer.apple.com/"
MINIMUM_SIZE_TO_DETECT_CORRUPTED_PDF=20

doGetWWDCPost2012 () {

	ituneslogin=$1
	itunespassword=$2
	FORMAT=$3
	
	if [ ${VERBOSE} == true ];
	then
	  echo "Sessions to be downloaded: ${SESSION_WANTED}"
	  echo "Output directory: ${WWDC_DIRNAME}"
	fi

	mkdir -p $TMP_DIR
    
    # Processing Authentifcation - depreciated now (but kept for copy/pasters like me that might need to use this as a snippet for other uses)
    if [ -z "${ituneslogin}" ];
    then
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
    else
        curl -silent ${VIDEO_URL} > $TMP_DIR/video.html
    fi

    cat ${TMP_DIR}/video.html | sed -e '/class="thumbnail-title/,/<div class="error">/!d' > $TMP_DIR/video-cleaned.html

	if [ -f ${TMP_DIR}/titles.txt ] ; then
		rm ${TMP_DIR}/titles.txt
	fi
    cat ${TMP_DIR}/video-cleaned.html | while read line; do 
		sessionNum=`echo $line | grep -o -E '<li class="thumbnail-title">(.*)</li><li class="thumbnail-(id|play)">(.*)</li>' | grep -o -E 'Session [0-9]*' | cut -d' ' -f2`
        title_array[$sessionNum]=`echo $line | grep -o -E '<li class="thumbnail-title">(.*)</li><li class="thumbnail-(id|play)">(.*)</li>' | cut -d'>' -f2 | sed 's/<\/li$//g'`
        echo "$sessionNum,${title_array[$sessionNum]}" >> $TMP_DIR/titles.txt
	done
    `sed -n '/^,/!p' $TMP_DIR/titles.txt > $TMP_DIR/titles.txt.tmp && mv $TMP_DIR/titles.txt.tmp $TMP_DIR/titles.txt` 

	while read line
	do
        sessionNum=`echo $line | cut -d',' -f1`
        sessionTitle=`echo $line | cut -d',' -f2`
		title_array[$sessionNum]=${sessionTitle}
	done < ${TMP_DIR}/titles.txt

    if [ ${LIST_MODE} == true ];
    then
        echo "Available videos:"
        echo "-----------------"
        cat ${TMP_DIR}/titles.txt | cut -d',' -f1 | while read line; do
        echo "${line}: ${title_array[$line]}"
        #printf '%s\n' "${title_array[@]}"
        done;
        exit
    fi


	echo "******* DOWNLOADING PDF FILES ********"

	# PDF
	mkdir -p "${WWDC_DIRNAME}"/PDFs

	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/PDFs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		# echo "Hello, de Lu!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/PDFs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi
    # cleaning possible corrupted pdf (downloaded with wrong path then with size of 16 octets)
    find "${WWDC_DIRNAME}"/PDFs/ -name "*.pdf" -size -2 -delete

	i=0
#	cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/'${YEAR}'\/[0-9a-zA-Z]*\/[0-9]{1,5}\/([0-9]{1,5}|[0-9]{1,5}_.*)\.pdf\?dl=1+)"' | cut -d'"' -f2 | sed -e 's/_sd_/_/g' -e 's/.mov/.pdf/g' | while read line; do    
	cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/'${YEAR}'\/[0-9a-zA-Z]*\/[0-9]{1,5}\/([0-9]{1,5}|[0-9]{1,5}_.*)\.pdf\?dl=1+)"' | cut -d'"' -f2 | sed -e 's/_sd_/_/g' -e 's/_hd_/_/g' -e 's/.mov/.pdf/g' | while read line; do    

        filename=`echo ${line} | cut -d'/' -f9 | cut -d'?' -f1`

		session_number=`echo $line | grep -o -E '\/([0-9]+|[0-9]+_.*)\.pdf' | grep -o -E "[0-9]{3,4}"`
		if [ ${SELECTIVE_SESSION_MODE} == true ];
		then
			if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
			then
				dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$session_number]}.pdf"
                old_dest_path="${WWDC_DIRNAME}/PDFs/${filename}"
				if [ -f "${dest_path}" ];
				then
					echo "${dest_path} already downloaded (nothing to do!)"
                elif  [ -f "${old_dest_path}" ];
                then
                    echo "Rename existing file: ${old_dest_path} => ${dest_path}"
                    mv  "${old_dest_path}" "${dest_path}"                    
				else
					echo "downloading PDF for session ${session_number}: $line" 

					curl $line > "${dest_path}.download"
		
					mv "${dest_path}.download" "${dest_path}"
				fi
			fi
		else
			dest_path="${WWDC_DIRNAME}/PDFs/${session_number} - ${title_array[$session_number]}.pdf"
			old_dest_path="${WWDC_DIRNAME}/PDFs/${filename}"
            
			if [ -f "${dest_path}" ];
			then
				echo "${dest_path} already downloaded (nothing to do!)"
            elif  [ -f "${old_dest_path}" ];
            then
                echo "Rename existing file: ${old_dest_path} => ${dest_path}"
                mv  "${old_dest_path}" "${dest_path}"
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
		echo "Cleaning non fully downloaded files: OK" 
	fi


    i=0
	# TODO: / WARNING (for possible future function merge): note that devstreaming url does use hard coded "wwdc" in it, were tech-talks function url is "techtalks" (whithout dash)
    
    if [ ${YEAR} = "2013" ];
    then
        REGEXFILE="[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}-${FORMAT}\.mov"
    elif [ ${YEAR} = "2014" ];
    then
        if [ "${FORMAT}" = "HD" ];
        then
            LC_FORMAT="hd"
        else
            LC_FORMAT="sd"
        fi
        REGEXFILE="[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}_${LC_FORMAT}_.*\.mov"
    else
        echo "coucou"
    fi

    cat ${TMP_DIR}/video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/'${YEAR}'/'${REGEXFILE}'\?dl=1+)"' | cut -d'"' -f2 | while read line; do 

        #echo $line
        filename=`echo ${line} | cut -d'/' -f9 | cut -d'?' -f1`

        session_number=`echo $line | grep -o -i -E '/[0-9]+[_-]'${FORMAT}'[^/]*.mov' | grep -o -E '[0-9]+' | head -1`
        if [ ${SELECTIVE_SESSION_MODE} == true ];
        then
            if `echo ${SESSION_WANTED} | grep "${session_number}" 1>/dev/null 2>&1`
            then
                dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$session_number]}-${FORMAT}.mov"
                old_dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${filename}"
                if [ -f "${dest_path}" ]
                then
                    echo "${dest_path} already downloaded (nothing to do!)"
                elif  [ -f "${old_dest_path}" ];
                then
                    echo "Rename existing file: ${old_dest_path} => ${dest_path}"
                    mv  "${old_dest_path}" "${dest_path}"
                else
                    echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

                    curl $line > "${dest_path}.download"

                    mv "${dest_path}.download" "${dest_path}"
                fi
            fi
        else
            dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${session_number} - ${title_array[$session_number]}-${FORMAT}.mov"
            old_dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${filename}"

            if [ -f "${dest_path}" ]
            then
                echo "${dest_path} already downloaded (nothing to do!)"
            elif  [ -f "${old_dest_path}" ];
            then
                echo "Rename existing file: ${old_dest_path} => ${dest_path}"
                mv  "${old_dest_path}" "${dest_path}"
            else
                echo "downloading ${FORMAT} Video for session ${session_number}: $line" 

                curl $line > "${dest_path}.download"

                mv "${dest_path}.download" "${dest_path}"
            fi
        fi
        ((i+=1))
    done

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


    if [ ${LIST_MODE} == true ];
    then
        echo "Available videos:"
        echo "-----------------"
        cat ${TMP_DIR}/titles.txt | cut -d';' -f1 | while read line; do
        echo "$line: ${title_array[$line]}"
        #printf '%s\n' "${title_array[@]}"
        done;
        exit
    fi


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
	#echo "DEBUG: do 2012 (login=${ituneslogin} - password=${itunespassword} - format=${FORMAT})"
	TMP_DIR="/tmp/wwdc2012-$UNIQID.tmp"
	mkdir -p $TMP_DIR

	echo ""
	echo "======> SORRY: 2012 VIDEO DOWNLOAD NOT YET IMPLEMENTED! <======="
	echo ""

	rm -Rf ${TMP_DIR}
}


#**************************************************************************************#
#                                   WWDC 2015                                          #
#**************************************************************************************#
doGetWWDC2015 () {
	ituneslogin=$1
	itunespassword=$2
	FORMAT=$3
	
	if [ ${VERBOSE} == true ];
	then
	  echo "Sessions to be downloaded: ${SESSION_WANTED}"
	  echo "Output directory: ${WWDC_DIRNAME}"
	fi

	mkdir -p $TMP_DIR
    
    # Processing Authentifcation - depreciated now (but kept for copy/pasters like me that might need to use this as a snippet for other uses)
    if [ -z "${ituneslogin}" ];
    then
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
    else
        curl -silent ${VIDEO_URL} > $TMP_DIR/video.html
    fi

    cat ${TMP_DIR}/video.html | sed -e '/class="inner_v_section"/,/<\/section>/!d' > $TMP_DIR/video-cleaned.html

	if [ -f ${TMP_DIR}/titles.txt ] ; then
		rm ${TMP_DIR}/titles.txt
	fi
    cat ${TMP_DIR}/video-cleaned.html | while read line; do 
        # domain if for future use ...
        #domain=`echo $line | grep -o -E '<h6>(.*)</h6>' | cut -d'<' -f2 | cut -d'>' -f2`
		sessionNum=`echo $line | grep -o -E '<a(.*)</a>' | cut -d'=' -f3 | cut -d'"' -f1`
        title_array[$sessionNum]=`echo $line | grep -o -E '<a(.*)</a>' | cut -d'>' -f2 | cut -d'<' -f1`
        echo "$sessionNum;${title_array[$sessionNum]}" >> $TMP_DIR/titles.txt
	done

    #`sed -n '/^,/!p' $TMP_DIR/titles.txt > $TMP_DIR/titles.txt.tmp && mv $TMP_DIR/titles.txt.tmp $TMP_DIR/titles.txt` 
    `sed '/^;/d' $TMP_DIR/titles.txt > $TMP_DIR/titles.txt.tmp && mv $TMP_DIR/titles.txt.tmp $TMP_DIR/titles.txt` 

    # escape special char for downloading issues (ex: I/O string)
    # Ok this is dirty, but quick ! ;)
    mv ${TMP_DIR}/titles.txt ${TMP_DIR}/titles-to-be-escaped.txt 
    sed -e 's/\//\-/g' ${TMP_DIR}/titles-to-be-escaped.txt > ${TMP_DIR}/titles.txt
    mv ${TMP_DIR}/titles.txt ${TMP_DIR}/titles-to-be-escaped.txt 
    sed -e 's/&/AND/g' ${TMP_DIR}/titles-to-be-escaped.txt > ${TMP_DIR}/titles.txt

    while read line
	do
        sessionNum=`echo $line | cut -d';' -f1`
        sessionTitle=`echo $line | cut -d';' -f2`
		title_array[$sessionNum]=${sessionTitle}
	done < ${TMP_DIR}/titles.txt
    
    
    
    if [ ${LIST_MODE} == true ];
    then
        echo "Available videos:"
        echo "-----------------"
        cat ${TMP_DIR}/titles.txt | cut -d';' -f1 | while read line; do
        echo "$line: ${title_array[$line]}"
        #printf '%s\n' "${title_array[@]}"
        done;
        exit
    fi

    echo "########## DOWNLOADING ${FORMAT} VIDEOS and PDFs files ##########"

    # PDFs
    mkdir -p "${WWDC_DIRNAME}/PDFs"
    # do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/PDFs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		# echo "Hello, de Lu!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/PDFs/*.download	
		echo "Cleaning non fully downloaded files: OK." 
	fi
    # cleaning possible corrupted pdf (downloaded with wrong path then with size of 16 octets)
    find "${WWDC_DIRNAME}"/PDFs/ -name "*.pdf" -size -2 -delete

	# Videos ${FORMAT}
	mkdir -p "${WWDC_DIRNAME}/${FORMAT}-VIDEOs"
	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		#echo "All downloads will go to your Desktop/WWDC-2013 folder!"
		:
	else
		echo "Some download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/${FORMAT}-VIDEOs/*.download	
		echo "Cleaning non fully downloaded files: OK" 
	fi
    
    
    # Prepare for SAMPLE-CODE
    mkdir -p "${WWDC_DIRNAME}/SAMPLE-CODE"
	# do the rm *.download only if files exist
	FILES_LIST="$(ls "${WWDC_DIRNAME}"/SAMPLE-CODE/*.download 2>/dev/null)"
	if [ -z "$FILES_LIST" ]; then
		#echo "Hope you like my code? I know there are lot's of improvment I could make. In particular split in functions ..."
		:
	else
		echo "Some sample code files download was aborted last time you ran this script."
		rm "${WWDC_DIRNAME}"/SAMPLE-CODE/*.download	
		echo "Cleaning non fully downloaded sample code zip files: OK" 
	fi



	i=0

    if [ "${FORMAT}" = "HD" ];
    then
        LC_FORMAT="hd"
    else
        LC_FORMAT="sd"
    fi
    REGEXFILE="[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}_${LC_FORMAT}_.*\.mp4"
    REGEXPDFFILE="[0-9a-zA-Z]*\/[0-9]{1,5}\/[0-9]{1,5}_.*\.pdf"
    
    # get individuals video pages
    cat ${TMP_DIR}/titles.txt | cut -d';' -f1 | while read line; do 
        curl -silent "${VIDEO_URL}?id=$line" > "${TMP_DIR}/$line-video.html";
        videoURL=`cat ${TMP_DIR}/$line-video.html | grep -o -E 'href="(http:\/\/devstreaming.apple.com\/videos\/wwdc\/'${YEAR}'/'${REGEXFILE}'\?dl=1+)"'| cut -d'"' -f2`
        pdfURL=`echo ${videoURL} | sed 's/_'${LC_FORMAT}'_/_/g' | sed 's/\.mp4/\.pdf/g'`
        #echo ${line}: ${pdfURL}
        
        # Get sample codes
        cat ${TMP_DIR}/$line-video.html | grep -o -E '(class="sample-code"|class="playground")(.*)</a>' | cut -d'"' -f4 > "${TMP_DIR}/${line}-sampleCodeURL.txt"
        cat ${TMP_DIR}/$line-video.html | grep -o -E '(class="sample-code"|class="playground")(.*)</a>' | cut -d'>' -f3 | cut -d'<' -f1 > "${TMP_DIR}/${line}-sampleCodeName.txt"
        paste -d';' "${TMP_DIR}/${line}-sampleCodeName.txt" "${TMP_DIR}/${line}-sampleCodeURL.txt" > "${TMP_DIR}/${line}-sampleCode.txt"
        
        # escape special char for downloading issues (ex: I/O string)
        # Ok this is dirty, but it need to be quick ! ;)
        mv ${TMP_DIR}/${line}-sampleCode.txt ${TMP_DIR}/${line}-sampleCode-to-be-escaped.txt 
        sed -e 's/I\/O/I\-O/g' ${TMP_DIR}/${line}-sampleCode-to-be-escaped.txt > ${TMP_DIR}/${line}-sampleCode.txt
        mv ${TMP_DIR}/${line}-sampleCode.txt ${TMP_DIR}/${line}-sampleCode-to-be-escaped.txt 
        sed -e 's/&/AND/g' ${TMP_DIR}/${line}-sampleCode-to-be-escaped.txt > ${TMP_DIR}/${line}-sampleCode.txt


        sampleCodeURL=()
        sampleCodeName=()
        nb_lines=0
        while read lineURL; do
            sampleCodePATHOnLine=`echo ${lineURL} | cut -d';' -f2`
            sampleCodeNameOnLine=`echo ${lineURL} | cut -d';' -f1`
            replacement=" -"
            sampleCodeNameOnLine="${sampleCodeNameOnLine/:/${replacement}}"
            if [[ ! ${lineURL} =~ \.zip$ ]];
            then
                curl -silent -L "${SAMPLE_CODE_ROOT_URL}/${sampleCodePATHOnLine}/book.json" > "${TMP_DIR}/$line-book.json";
                sampleCodeURL[nb_lines]=`cat "${TMP_DIR}/$line-book.json" | grep -o -E '"sampleCode":".*\.zip"' | cut -d'"' -f4`
                sampleCodeName[nb_lines]=${sampleCodeNameOnLine}
                sampleCodePATH=${sampleCodePATHOnLine}
                #echo " (${nb_lines})${sampleCodeName[nb_lines]}: ${SAMPLE_CODE_ROOT_URL}/${sampleCodePATHOnLine}/${sampleCodeURL[nb_lines]}"
            else
                sampleCodeURL[nb_lines]=${sampleCodePATHOnLine}
                #sampleCodeName[nb_lines]=${lineURL%.*}
                sampleCodeName[nb_lines]=${sampleCodeNameOnLine}
                sampleCodePATH=${sampleCodeURL[nb_lines]}
                #echo "==> Direct zip: ${sampleCodeName[nb_lines]}: ${SAMPLE_CODE_ROOT_URL}/${sampleCodeURL[nb_lines]}/${sampleCodeURL[nb_lines]}"
            fi            
            ((nb_lines+=1))
        done < "${TMP_DIR}/${line}-sampleCode.txt"
        
        if [ ${SELECTIVE_SESSION_MODE} == true ];
        then
            if `echo ${SESSION_WANTED} | grep "${line}" 1>/dev/null 2>&1`
            then

                # downloading PDF file
                dest_path="${WWDC_DIRNAME}/PDFs/${line} - ${title_array[$line]}.pdf"
                if [ -f "${dest_path}" ]
                then
                    echo "${dest_path} already downloaded (nothing to do!)"
                else
                    echo "downloading PDF doc for session ${line}: ${title_array[$line]}" 
                    curl "${pdfURL}" > "${dest_path}.download" && mv "${dest_path}.download" "${dest_path}"
                fi

                # downloading video files
                dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${line} - ${title_array[$line]}-${FORMAT}.mov"
                if [ -f "${dest_path}" ]
                then
                    echo "${dest_path} already downloaded (nothing to do!)"
                else
                    echo "downloading ${FORMAT} Video for session ${line}: ${title_array[$line]}" 
                    curl "${videoURL}" > "${dest_path}.download" && mv "${dest_path}.download" "${dest_path}"
                fi

                # downloading sample codes files
                for i in "${!sampleCodeURL[@]}"; do
                    #if [ -n "${sampleCodeURL[$i]}" ]; then
                        dest_path="${WWDC_DIRNAME}/SAMPLE-CODE/${line} - ${sampleCodeName[$i]}.zip"
                        if [ -f "${dest_path}" ]
                        then
                            echo "${dest_path} already downloaded (nothing to do!)"
                        else
                            fileToLink=`find "${WWDC_DIRNAME}/SAMPLE-CODE/" -name "* ${sampleCodeName[$i]}.zip" | sed -n 1p`
                            echo "fileToLink=${fileToLink}"
                            if [[ -z "${fileToLink}" ]]; then
                                echo "downloading sample code for session ${line}: ${sampleCodeName[$i]}" 
                                echo "${SAMPLE_CODE_ROOT_URL}/${sampleCodePATH}/${sampleCodeURL[$i]}"
                                curl -L "${SAMPLE_CODE_ROOT_URL}/${sampleCodePATH}/${sampleCodeURL[$i]}" > "${dest_path}.download" && mv "${dest_path}.download" "${dest_path}"
                            else
                                echo "==> package already exist: creating simlink for (${line}: ${sampleCodeName[$i]})"
                                ln -s "${fileToLink}" "${WWDC_DIRNAME}/SAMPLE-CODE/${line} - ${sampleCodeName[$i]}.zip"
                            fi
                        fi
                    #fi
                done
            fi
        else

            # downloading PDF file
            dest_path="${WWDC_DIRNAME}/PDFs/${line} - ${title_array[$line]}.pdf"
            if [ -f "${dest_path}" ]
            then
                echo "${dest_path} already downloaded (nothing to do!)"
            else
                if [[ ${line} != "103" && ${line} != "101" ]] #there is no point having pdf for Apple design Award or the Keynote
                then 
                    echo "downloading PDF doc for session ${line}: ${title_array[$line]}" 
                    curl -L "${pdfURL}" > "${dest_path}.download" && mv "${dest_path}.download" "${dest_path}"
                fi
            fi

            # downloading videos
            dest_path="${WWDC_DIRNAME}/${FORMAT}-VIDEOs/${line} - ${title_array[$line]}-${FORMAT}.mov"
            if [ -f "${dest_path}" ]
            then
                echo "${dest_path} already downloaded (nothing to do!)"
            else
                echo "downloading ${FORMAT} Video for session ${line}: ${title_array[$line]}" 
                curl -L "${videoURL}" > "${dest_path}.download" && mv "${dest_path}.download" "${dest_path}"
            fi

            # downloading sample codes files
            for i in "${!sampleCodeURL[@]}"; do
                #if [ -n "${sampleCodeName[$i]}" ]; then
                    dest_path="${WWDC_DIRNAME}/SAMPLE-CODE/${line} - ${sampleCodeName[$i]}.zip"
                    if [ -f "${dest_path}" ]
                    then
                        echo "${dest_path} already downloaded (nothing to do!)"
                    else
                        fileToLink=`find "${WWDC_DIRNAME}/SAMPLE-CODE/" -name "* ${sampleCodeName[$i]}.zip" | sed -n 1p`
                        if [[ -z "${fileToLink}" ]]; then
                            echo "downloading sample code for session ${line}: ${sampleCodeName[$i]}" 
                            curl -L "${SAMPLE_CODE_ROOT_URL}/${sampleCodePATH}/${sampleCodeURL[$i]}" > "${dest_path}.download" && mv "${dest_path}.download" "${dest_path}"
                        else
                            echo "==> package already exist: creating simlink for (${line}: ${sampleCodeName[$i]})"
                            ln -s "${fileToLink}" "${WWDC_DIRNAME}/SAMPLE-CODE/${line} - ${sampleCodeName[$i]}.zip"
                        fi
                    fi
                #fi
            done
        fi
        ((i+=1))

    done; 

    rm -Rf ${TMP_DIR}
}

checkNetwork () {
    curl -silent -D- -o /dev/null -s http://www.google.com 1>/dev/null 2>&1
    if [[ $? == 0 ]]; then
        :
        #echo "there is netxork"
    else
        echo "No network connexion! Man, you're here for a long walk!"
        exit 1
    fi
}

##########################################################################################
#######                      		   MAIN 									##########
##########################################################################################

#if [ $# -eq "0" ]
#then
#  echo "WWDC videos and PDFs downloader (version ${VERSION})" >&2
#  echo "Usage: `basename $0` [options] <Apple dev login>"
#  echo "Please use -h for more options"
#  exit 1
#fi

ituneslogin=${@: -1}
FORMAT=${DEFAULT_FORMAT}
YEAR=${DEFAULT_YEAR}
EVENT=${DEFAULT_EVENT}

while getopts ":hl:y:f:s:vLo:e:" opt; do
  case $opt in
    h)
	  	echo "WWDC Videos and PDFs downloader (version ${VERSION})" >&2
        echo "Author: Olivier HO-A-CHUCK (http://blog.hoachuck.biz)"
      	echo ""
	  	echo "Usage: 	`basename $0` [options]"
	  	echo "Try -L option for list of available videos"
        echo ""
	  	echo "Options:"
      	echo "	-y <year>: select year (ex: -y 2013). Default year is 2015" >&2
      	echo "		Possible values for year: 2013, 2014 and 2014" >&2
      	echo "		For info: year 2012 videos download is not yet available - to be honest, I'm too lazy to do it!" >&2
      	echo "	-e <event>: select event type between \"wwdc\" and \"tech-talks\"" >&2
      	echo "		default value is \"wwdc\"" >&2
      	echo "	-f <format>: select video format type (SD or HD). Default video format is SD" >&2
      	echo "	-s <comma separated session numbers>: select which sessions you want to download (try -L option for list of avialable videos)" >&2
      	echo "	-v : verbose mode" >&2
      	echo "	-o <output path>: path where to download content (default is /Users/${USER}/Documents/WWDC-<selected year|default=2015>)" >&2
      	echo "	-l [Not needed anymore] <iTunes login>: Give your Developer portal login (so far you don't need to login anymore. If this does change, please use -l option)." >&2
      	echo "	-L : List available video sessions" >&2
      	echo ""  >&2
        echo ""
      	echo "Most common usage:"  >&2
      	echo "	- Download all available SD videos for wwdc 2015:"  >&2
      	echo "  		`basename $0`"  >&2
        echo ""
      	echo "Other examples:"  >&2
      	echo "	- Download all PDFs and SD videos for wwdc 2014 if Apple change his mind and ask for login:" >&2
        echo "  		`basename $0` -y 2014"  >&2
      	echo "	- Download all PDFs and SD videos for tech-talks 2013:"  >&2
      	echo "  		`basename $0` -y 2013 -e tech-talks"  >&2
      	echo "	- Download all HD videos for wwdc 2015:"  >&2
      	echo "  		`basename $0` -f HD"  >&2
      	echo "	- Download only session 201, 400 and 401 with SD videos for wwdc 2015:"  >&2
      	echo "  		`basename $0` -s 201,400,401"  >&2
      	echo "	- Download only session 201 and 400 with HD video for wwdc 2015:"  >&2
      	echo "  		`basename $0` -s 201,400 -f HD"  >&2
      	echo "	- Download all HD videos for wwdc 2015 in /Users/${USER}/Desktop/WWDC-2014 using verbose mode:"  >&2
      	echo "  		`basename $0` -v -f HD -o /Users/${USER}/Desktop/WWDC-2014"  >&2
      	echo ""
      	exit 0;
      	;;
    l)
	  	ITUNES_LOGIN=${OPTARG}
        LOGIN=true
	  	;;
    y)
      	if [ $OPTARG = "2012" ] || [ $OPTARG = "2013" ] || [ $OPTARG = "2014" ] || [ $OPTARG = "2015" ];
      	then
	  		YEAR=$OPTARG
	  	else
	  		echo "Unknown specified year. Using default (${YEAR})!"
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
    L)
      	LIST_MODE=true
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
  
WWDC_DIRNAME=${WWDC_DIRNAME:-"${HOME}/Documents/WWDC-${YEAR}"}

case "${YEAR}" in
"2012")
    if [ -z ${ITUNES_LOGIN} ];
    then   
        read -r -p Login: ituneslogin ; echo
    fi
    if $LOGIN
    then
        read -r -s -p Password: itunespassword ; echo
    else
        echo ""
        echo "Using 'no password' mode (this is possible since WWDC 2014 sessions addition => Apple bug ?)!"
        echo "try using -l option if download does not work."
        echo ""
        ituneslogin="<no-login>"
        itunespassword="<no-password>"
    fi
    checkNetwork
	doGet2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	;;
"2013")
    #if [ -z ${ITUNES_LOGIN} ];
    #then   
    #    read -r -p Login: ituneslogin ; echo
    #fi
    checkNetwork

    if $LOGIN ;
    then
        read -r -s -p Password: itunespassword ; echo
    else
        echo ""
        echo "Using 'no password' mode (this is possible since WWDC 2014 sessions addition => Apple bug ?)!"
        echo "try using -l option if download does not work."
        echo ""
        ituneslogin="<no-login>"
        itunespassword="<no-password>"
    fi
	if [ ${EVENT} == "wwdc" ];
	then
		VIDEO_URL=${VIDEO_URL_WWDC}/2013/
		doGetWWDCPost2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	elif [ ${EVENT} == "tech-talks" ];
	then
		VIDEO_URL=${VIDEO_URL_TECHTALK}
		doGetTT2013 ${ituneslogin} ${itunespassword} ${FORMAT}
	fi
	;;
"2014")
    if $LOGIN ;
    then
        read -r -s -p Password: itunespassword ; echo
    else
        echo ""
        echo "Using 'no password' mode (this is possible since WWDC 2014 sessions addition => Apple bug ?)!"
        echo "try using -l option if download does not work."
        echo ""
        ituneslogin="<no-login>"
        itunespassword="<no-password>"
    fi
	if [ ${EVENT} == "wwdc" ];
	then
		VIDEO_URL=${VIDEO_URL_WWDC}/2014/
		doGetWWDCPost2012 ${ituneslogin} ${itunespassword} ${FORMAT}
	elif [ ${EVENT} == "tech-talks" ];
	then
		#VIDEO_URL=${VIDEO_URL_TECHTALK}
		#doGetTT2013 ${ituneslogin} ${itunespassword} ${FORMAT}
        echo "No yet available session download other than 'wwdc' for 2014! Sorry man."
	fi
	;;
"2015")
    checkNetwork

    if $LOGIN ;
    then
        read -r -s -p Password: itunespassword ; echo
    else
        echo ""
        echo "Using 'no password' mode (this is possible since WWDC 2014 sessions addition)!"
        echo "try using -l option if download does not work."
        echo ""
        ituneslogin="<no-login>"
        itunespassword="<no-password>"
    fi

    if [ ${EVENT} == "wwdc" ];
	then
		VIDEO_URL=${VIDEO_URL_WWDC}/2015/
		doGetWWDC2015 ${ituneslogin} ${itunespassword} ${FORMAT}
	elif [ ${EVENT} == "tech-talks" ];
	then
        echo "There is no TechTalk sessions available yet for 2015! Sorry for that sir."
	fi
	;;
*)
	echo "Sorry: can't process requested year. Please choose between \"2012\", \"2013\" , \"2014\" or \"2015\"."
#	;;
esac

exit 0
