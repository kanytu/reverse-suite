#!/usr/bin/env bash

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# vim:ts=5:sw=5:expandtab
# we have a spaces softtab, that ensures readability with other editors too

[ -z "$BASH_VERSINFO" ] && printf "\n\033[1;35m Please make sure you're using \"bash\"! Bye...\033[m\n\n" >&2 && exit 245
[ $(kill -l | grep -c SIG) -eq 0 ] && printf "\n\033[1;35m Please make sure you're calling me without leading \"sh\"! Bye...\033[m\n\n"  >&2 && exit 245

# Initialize our own variables:
output=false
no_opt=false
#######
BASEDIR="$(dirname $0)/../"
private_key="../tools/"
ca_cert="./tools/"
output_dir="$BASEDIR/output/"



#######

show_logo() {
    echo "  _____                                 _____       _ _       
 |  __ \                               / ____|     (_) |      
 | |__) |_____   _____ _ __ ___  ___  | (___  _   _ _| |_ ___ 
 |  _  // _ \ \ / / _ \ '__/ __|/ _ \  \___ \| | | | | __/ _ \ 
 | | \ \  __/\ V /  __/ |  \__ \  __/  ____) | |_| | | ||  __/
 |_|  \_\___| \_/ \___|_|  |___/\___| |_____/ \__,_|_|\__\___|
                                                                                                                            "    
}
show_help() {
     cat << EOF
$0 <options>, where <options> are:

     -h                        what you are looking at
     -d <file.apk>,            disassemble the apk (convert to smali)
     -l,                       shows the name of the applications already disassembled.
     -b <application_name>,    build the provided application as an apk. 
     -n,                       optimize images during build.
     -x <file.apk>,            decompile the apk, and run luyten to verify the source code.
     -o <file.apk>,            output file of the new apk (use with -d)

EOF
}

view_apps() {
    tmp=($(ls -d ../output/*/ 2> /dev/null | cut -f3 -d'/')) 
    if (( ${#tmp[@]} == 0 )); then
        echo "[Error] No disassembled apps found" >&2
        exit 0
    else
        echo "The applications you've extracted are: "
        for x in "${tmp[@]}"; do echo " " $x; done;
        echo -e "\nTo build one of the apps use: $0 -b ${tmp[0]} -o newfile.apk"
    fi
}

disassemble_app() {
    [ ! -f $1 ] && echo "The file \"$1\" doesn't exist. Please specify a correct apk file." && exit 0
    suggest_name=$(basename $1 | sed -e "s/.apk//g")
    read -e -p "Provide a name to save this app: " -i "$suggest_name " response
    if [ -d "$output_dir/$response" ]; then
        opt_remove="N"
        read -r -p "Directory exists. Can I remove it first? [y/N] " opt_remove
        case "$opt_remove" in
            [yY]) 
                rm -r $output_dir/$response
                java -jar "$BASEDIR/tools/others/apktool.jar" d "$1" -o "$output_dir/$response"
                ;;
            *)
                read -e -p "Provide a name to save this app: " -i "$suggest_name " response
                java -jar "$BASEDIR/tools/others/apktool.jar" d "$1" -f -o "$output_dir/$response" 
                ;;
        esac
    else
        java -jar "$BASEDIR/tools/others/apktool.jar" d "$1" -o "$output_dir/$response"
    fi
    
    if [ -d "$output_dir/$response" ]; then
        echo -e "\nExtracted files can be found here: \"$(readlink -e $output_dir/$response)\""
    fi
}

decompile_app() {
    [ ! -f $1 ] && echo "The file \"$1\" doesn't exist. Please specify a correct apk file." && exit 0
    suggest_name=$(basename $1 | sed -e "s/.apk//g")
    opt_remove="N"
    echo "This option will remove any file with the name \"$suggest_name.jar\" (inside the ../output/ directory); will decompile the new file and open luyten."
    read -r -p "Do you want to continue? [y/N] " opt
    case "$opt" in
        [yY]) 
            rm $output_dir/$suggest_name.jar 2> /dev/null
            bash "$BASEDIR/tools/dex2jar/d2j-dex2jar.sh" -f -o "$output_dir/$suggest_name.jar" "$1"
            java -jar "$BASEDIR/tools/gui/luyten.jar" "$output_dir/$suggest_name.jar" &
            ;;
        *)
            echo "[Info] Aborting.."
            ;;
    esac
}
build_app() {
    [ ! -d $output_dir/$2 ] && echo -e "The application \"$2\" doesn't exist in the '../output/' directory.\nPlease use $0 -d <file.apk> first." && exit 0
    if [ -f $3 ]; then
        echo "The file \"$3\" already exist."
        read -r -p "Do you want to replace it? [y/N] " opt
        case "$opt" in
            [yY]) 
                rm $3
                ;;
            *)
                echo -e "\n[Info] So.. choose a diferent output name.. :|"
                exit 0
                ;;
        esac
    fi

    if [ -z $1 ]
    then
        echo "Optimazing the images in $output_dir/$2 - takes a while"
        find "$output_dir/$2" -name '*.png' ! -name '*.9.png' | xargs "$BASEDIR/tools/others/optipng" -o5
    fi
    echo "Building the app"
    java -jar "$BASEDIR/tools/others/apktool.jar" b "$output_dir/$2" -o "$3" 2> /dev/null

    echo "Running alignment tool for Android application files"
    rm $3_tmp 2> /dev/null
    "$BASEDIR/tools/others/zipalign" 4  "$3" "$3_tmp"

    echo "Signing the app"
    java -jar "$BASEDIR/tools/others/signapk.jar" "$BASEDIR/tools/others/debugkey.x509.pem" "$BASEDIR/tools/others/debugkey.pk8" "$3_tmp" "$3"
    rm $3_tmp 2> /dev/null

    if [ -f $3 ]; then
        echo -e "\nAll done. You can now install the app: $3"
    else
        echo -e "\n[Error] Something went wrong. It was not possible to locate $3"
    fi


}
show_logo

while getopts ":h?vo:d:lnb:x:" opt; do
    case "$opt" in
        h|\?)
            show_help
            exit 0
            ;;
        d)  disassemble_app ${OPTARG}
            ;;
        l)  view_apps; exit 0
            ;;
        b)  path=${OPTARG}
            build_arg=true
            ;;
        x)  decompile_app ${OPTARG}
            ;;
        n)  no_opt=true
            ;;
        o)  output=${OPTARG};
            build_app $no_opt $path $output
            output_arg=true
            ;;
        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ $output_arg ]
then
    if [ -z $build_arg ]
    then
        echo "[Error] -o must be included when you build an app (-b)" >&2
        exit 1
    fi
fi

# End of file
