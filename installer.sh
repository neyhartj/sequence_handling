#!/bin/bash

#set -e
#set -u
#set -o pipefail

#   This script installs Sickle, Seqqs, and Scythe
#   from GitHub. No GitHub account is required for
#   this installation to occur


#   Create a software directory for these three programs in home directory
#   These paths can be changed to match your hierarchy
#   Note where Seqqs is installed, this is needed in
#   QSub_trim_autoplot.sh to tell where to look for
#   the quality trimming script

usage() {
    echo -e "\
Usage: ./installer.sh install \n\
\n\
This script installs 'Sickle', 'Scythe' and 'Seqqs' from GitHub for use \n\
with other scripts in this workflow. This script will spit out the path for the \n\
'Seqqs' directory. This needs to be put into 'Quality Trimming.sh' before use. \n\
\n\
These programs are NOT permanently added to your PATH. To do so, follow on-screen \n\
prompts or run ./installer.sh echo \n\
" >&2
    exit 1
}

not_installed() {
echo "Please make sure you have Sickle, Seqqs, Scythe installed on your system"
sleep 2
echo "Run ./installer.sh install to do so"
sleep 2
exit 1
}

case "$1" in
    "install" )
        ROOT="${HOME}"
        if [ -d "${ROOT}"/software ]; then
            cd "${ROOT}"/software
            SOFT=`pwd`
        else
            cd "${ROOT}"
            mkdir software
            cd software
            SOFT=`pwd`
        fi
        #   Install Seqqs from the MorrellLab Seqqs GitHub Repository
        echo "Fetching Seqqs from GitHub"
        cd "${SOFT}"
        git clone https://github.com/MorrellLab/seqqs.git
        cd seqqs
        echo "Installing Seqqs"
        make
        echo "Done"
        SEQQS_DIR=`pwd`
        echo "Seqqs directory is ${SEQQS_DIR}"
        echo 'This needs to be written in "QSub_trim_autoplot.sh"'
        export PATH="$PATH":"${SEQQS_DIR}"
        #   Install Sickle from Vince Buffalo's Sickle GitHub Repository
        echo "Fetching Sickle from GitHub"
        cd "${SOFT}"
        git clone https://github.com/vsbuffalo/sickle.git
        cd sickle
        echo "Installing Sickle"
        make
        echo "Done"
        SICKLE_DIR=`pwd`
        export PATH="$PATH":"${SICKLE_DIR}"
        #   Install Scythe from Vince Buffalo's Scythe GitHub repository
        echo "Fetching Scythe form GitHub"
        cd "${SOFT}"
        git clone https://github.com/vsbuffalo/scythe.git
        cd scythe
        echo "Installing Scythe"
        make all
        echo "Done"
        SCYTHE_DIR=`pwd`
        export PATH="$PATH":"${SCYTHE_DIR}"
            echo "Please note that each of these programs has been added to your PATH"
        sleep 3
        echo "This allows them to be called without being in their respective directories"
        sleep 3
        echo
        echo "However, this only works for this terminal window THIS TIME only"
        sleep 3
        echo
        echo "If you want to have these programs permanently added to your PATH"
        sleep 2
        echo 'Please write "export PATH:$PATH:<full file path/>" in .bash_profile'
        echo "found in your home directory"
        sleep 3
        echo
        echo "The full paths for these programs are"
        sleep 2
        echo "Seqqs: $SEQQS_DIR"
        sleep 2
        echo "Sickle: $SICKLE_DIR"
        sleep 2
        echo "Scythe: $SCYTHE_DIR"
        sleep 3
        echo
        echo 'Put these in place of "<full file path/>" for each of the three programs'
        sleep 3
        ;;
    "echo" )
        if `command -v seqqs > /dev/null 2> /dev/null`
        then
            if `command -v sickle > /dev/null 2> /dev/null`
            then
                if `command -v scythe > /dev/null 2> /dev/null`
                then
                    echo "If you want to have Sickle, Scythe, and Seqqs permanently added to your PATH"
                    sleep 2
                    echo 'Please write "export PATH:$PATH:<full file path/>" in .bash_profile'
                    echo "found in your home directory"
                    sleep 3
                    echo 'Put the path to the directories in place of "<full file path/>" for each of the three programs'
                    sleep 3
                else
                    not_installed
                fi
            else
                not_installed
            fi
        else
            not_installed
        fi
        ;;
    * )
        usage
        ;;
esac
