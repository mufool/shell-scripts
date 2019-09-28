#!/bin/bash

getType(){
    echo "1 : Download and install to current folder"
    echo "2 : Download only"
    echo "q : Quit"
    while(true) ;do
        echo -n "Enter a value:"
        read choice < /dev/tty
        if [ "$choice" = "q" ];then exit 0;fi
        if [ "$choice" -gt "0" 2>/dev/null ] && [ "$choice" -lt "4" 2>/dev/null ]; then
            return $choice;
        else
            echo "$choice is not valid option!"
        fi
    done 
}

do_download(){
    fetch_dir=$1;
    if [ ! -d $fetch_dir ]; then
        echo "$fetch_dir is not vaild!"
        exit 1;
    fi
    cd $fetch_dir
    test_exists $fetch_dir
    set +e
    type "git" >/dev/null 2>/dev/null
    has_git=$?
    set -e
    if [ "$has_git" -eq 0 ];then
        echo "fetching source from github"
        do_fetch  $fetch_dir;
    else
        echo "can't locate git, using archive mode."
        do_download_archive $fetch_dir;
    fi
    echo "shell-scripts is downloaded to $fetch_dir/shell-scripts"
}

do_download_archive(){
    wget https://codeload.github.com/mufool/shell-scripts/zip/master -O shell-scripts.zip
    unzip shell-scripts.zip
    rm -rf shell-scripts.zip
    mv shell-scripts-master shell-scripts
    cd shell-scripts
}

do_fetch(){
    fetch_dir=$1;
    if [ ! -d $fetch_dir ]; then
        echo "$fetch_dir is not vaild!"
        exit 1;
    fi
    cd $fetch_dir ;
    test_exists shell-scripts;
    if [[ $# < 2 || "$2" = "git" ]]; then
        git clone https://github.com/mufool/shell-scripts.git shell-scripts --depth=1
    else
        svn checkout https://github.com/mufool/shell-scripts/trunk shell-scripts
    fi
    cd shell-scripts 
    return 0 
}

test_exists(){
    if [ -e shell-scripts ]; then
        echo "$1/shell-scripts already exist!"
        while(true);do
            echo -n "(q)uit or (r)eplace?"
            read choice < /dev/tty
            if [ "$choice" = "q" ];then
                exit 0;
            elif [ "$choice" = "r" ];then
                rm -fr $1/shell-scripts
                break;
            else
                echo "$choice is not valid!"
            fi  
        done
    fi
}

do_install(){
    echo '***install need sudo,please enter password***'
    sudo make install
    echo 'shell-scripts was installed to /usr/local/bin,have fun.'
}

main(){
    getType
    type=$?
    set -e
    case "$type" in 
        ("1")
            echo "Launching shell-scripts installer..."
            do_download `pwd`
            do_install
            ;;
        ("2")
            echo "Start downloading shell-scripts ..."
            do_download `pwd`
            ;;
    esac
}

main "$@"
