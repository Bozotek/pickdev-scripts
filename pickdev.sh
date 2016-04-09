#!/bin/bash

usage="./pickdev 'project_name'"

if [ $# -ne 1 ]; then
    echo $usage
    exit 1
fi

asked_project=$1
user=$(id -un)
dev_home_dir="/home/"$user"/rendu/PickaGuide"
project_dir=$dev_home_dir"/"$asked_project
dev_dir="/var/www/html"
backup_folder=""

## Get current project name in /var/www/html

function get_project_name {
    echo `cat project.id | tr -d '\n'`
}

## Compare the git version to see if a backup is necessary

function compare_git_versions {
    git diff $1 $2 > /dev/null
}

## Compare the files to see if a backup is necessary

function compare_files {
    diff -r $1 $2 > /dev/null
}

## Removes all the files from a folder, including .git and .gitignore

function clean_folder {
    rm -rf $1"/"*
    rm -rf $1"/.git"
    rm -rf $1"/.gitignore"
    echo "Removed all files from $1"
}

## Check if the project we're asking exists

function check_project_existence {
    if [ ! -d "$project_dir" ]; then
    	echo "$asked_project doesn't exist or the projects folder $dev_home_dir isn't correct"
    	exit 1
    fi

    cd $project_dir

    if [ ! -f "project.id" ]; then
    	echo "project folder $project_dir doesn't contain a project.id file"
    	exit 1
    fi

    check_name=$(get_project_name)

    if [ "$check_name" != "$asked_project" ]; then
    	echo "The project.id contains $check_name, which isn't the project asked for"
    	exit 1
    fi
}

## Create a backup folder based on a name and a timestamp

function create_backup_folder {
    cd $dev_home_dir

    compare_git_versions $dev_dir $dev_home_dir"/"$1
    if [ "$?" -eq 0 ]; then
        compare_files $dev_dir $dev_home_dir"/"$1
        if [ "$?" -eq 0 ]; then
            echo "No need to create a backup folder, project versions don't differ"
            clean_folder $dev_dir
            return
        fi
    fi

    timestamp=`date +%s`
    backup_name=$1"_"$timestamp

    if [ -d "$backup_name" ]; then
	    printf "Are you a genius? Cuz the backup folder $backup_name already exists"
	    exit 1
    fi

    mkdir $backup_name
    backup_folder=$dev_home_dir"/"$backup_name
}

## Check what kind of project or files are already in place

function check_current_project {
    cd $dev_dir

    if [ $? -ne 0 ]; then
    	echo "What the fuck ?? You haven't even installed apache ?"
    	exit 1
    fi

    if [ ! "$(ls -A .)" ]; then
    	echo "0"
    else
    	if [ -f "project.id" ]; then
            current_project=$(get_project_name)
            if [ "$current_project" = "$asked_project" ]; then
                echo "3"
            else
        	    echo "2"
            fi
    	else
    	    echo "1"
    	fi
    fi
}

## Move files from a point A to point B

function move_files {
    mv $1"/"* $2
    mv $1"/.git/" $2 2> /dev/null
    mv $1"/.gitignore" $2 2> /dev/null
    echo "Moved files from "$1" to "$2
}

## Copy files from a point A to point B

function copy_files {
    cp -r $1"/"* $2
    cp -r $1"/.git/" $2 2> /dev/null
    cp -r $1"/.gitignore" $2 2> /dev/null
    echo "Copied files from "$1" to "$2
}

## Backup current project

function backup_project {
    cd $dev_dir
    name=$(get_project_name)
    create_backup_folder $name
    if [ "$backup_folder" != "" ]; then
        move_files $dev_home_dir"/"$name $backup_folder
        move_files $dev_dir $dev_home_dir"/"$name
    fi
}

## Backup current files

function backup_files {
    create_backup_folder "Temporary"
    if [ "$backup_folder" != "" ]; then
        move_files $dev_dir $backup_folder
    fi
}

## Move project to the dev folder

function prepare_project {
    copy_files $project_dir $dev_dir
}

function __main__ {
    check_project_existence
    has_current_project=$(check_current_project)

    if [ "$has_current_project" -eq 3 ]; then
        echo "The project is already in $dev_dir, nothing to do"
        exit 1
    fi

    if [ "$has_current_project" -eq 2 ]; then
        backup_project
    elif [ "$has_current_project" -eq 1 ]; then
        backup_files
    fi

    prepare_project
}

__main__
