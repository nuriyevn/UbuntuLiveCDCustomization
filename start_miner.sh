#!/bin/bash

cpu_count=$(cat /proc/cpuinfo | grep processor | wc -l)
#echo "$cpu_count"

if [ "$cpu_count" == "24" ];
then
        sudo rm -rf /r16
        cd /r12
        sudo ln -s /r12 /r
        sudo /r12/xmrig -l
        #actually specifying  path for log.txt doesn't matter it will create in the working directory where the command has been invoked
elif [ "$cpu_count" == "32" ]
then
        sudo rm -rf /r12
        cd /r16
        sudo ln -s /r16 /r
        sudo /r16/xmrig -l
fi
