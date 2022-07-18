#!/bin/bash
R=0
V=0
ix=0
i_s=0

############### * FLAGS CHECKS
# Verbose messages
verbose_no_file() {
    if [ $V -eq 1 ] ; then  echo "The '$1' does not exist - ignoring."; fi
}
verbose_bad_format() {
    if [ $V -eq 1 ] ; then  echo "The '$1' does not have proper format - ignoring."; fi
}
verbose_ok() {
    if [ $V -eq 1 ] ; then  echo "The '$1' is decompressing .."; fi
}

############### * F * ########################
# Main when file
main_f() {    
    for FILE in $ARCHS
    do
	    if [ -d $FILE ] ; then
			dict_f $FILE
        elif [ ! -f $FILE ] ; then 
	        ix=$(( $ix+1 ))
	        verbose_no_file $FILE
	    else
	        ft_ch $FILE
	        decompr $TYPE $FILE
	    fi
    done
}

# Main for dictionaries
main_dd() {
	for FILE in $ARCHS
	do
    ft_ch $FILE
	decompr $TYPE $FILE
    done
}

# File type check
ft_ch() {
    TYPE=$(file -b $1 | cut -d ' ' -f 1)
}

# Dictionary function , checking if recursive
dict_f() {
    if [ $R -eq 1 ] ; then 
	    ARCHS=$(find $FILE -type f )
		main_dd $ARCHS
    else
		ARCHS=$(find $FILE -maxdepth 1 -type f)
		main_dd $ARCHS
	fi
}

# Decompress cases $1 arg-type, $2 - file-name
decompr() {
    case "$1" in 
	"Zip"    )           unzip -uqq    $2 && verbose_ok $2 && i_s=$(( $i_s+1 )) ;;
	"bzip2"  )           bunzip2 -kfd  $2 && verbose_ok $2 && i_s=$(( $i_s+1 )) ;;
	"gzip"   )           gunzip -fkdq  $2 && verbose_ok $2 && i_s=$(( $i_s+1 )) ;;
	"compress'd" )       mv $2 $2.Z && uncompress -df $2.Z && verbose_ok $2 && i_s=$(( $i_s+1 )) ;;
	*        )           ix=$(( $ix+1 )) && verbose_bad_format $2 ;;
    
    esac
}

################## * BEGIN * ###################
# Banner
if [ $# -eq 0 ] ; then 
    echo ""
    echo    "Unpackme 2022 "
    echo -e "Please fallow the syntax \n"
    echo    "unpack [-r] [-v] file [file...]"
    echo    " -r    traverse all provided path"
    echo -e " -v    verbose\n"
    exit 1
fi

# Setting values for flags
i=0
for each in $@
do
    i=$(( i+1 ))
    if [ $each == -v ] ; then V=1 ; fi
    if [ $each == -r ] ; then R=1 ; fi
done

# Throwing away -v and -r if exist from all archives
ARCHS=$(echo $* | sed 's/\-r//' | sed 's/\-v//')

main_f

# Counters
echo "Ignored $ix file(s)."	
echo "Decompressed $i_s archive(s)."
