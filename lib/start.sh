#!/usr/bin/env bash

echo "\$1 is $1"
if [ "$1" == 'train' ]
then
	echo "In train start.sh"
    # Remove all nvidia gl libraries if they exists to run training in SageMaker.
    rm -rf /usr/local/nvidia/lib/libGL*
    rm -rf /usr/local/nvidia/lib/libEGL*
    rm -rf /usr/local/nvidia/lib/libOpenGL*
    rm -rf /usr/local/nvidia/lib64/libGL*
    rm -rf /usr/local/nvidia/lib64/libEGL*
    rm -rf /usr/local/nvidia/lib64/libOpenGL*

    CURRENT_HOST=$(jq .current_host  /opt/ml/input/config/resourceconfig.json)
	echo "Current host is $CURRENT_HOST"

    sed -ie "s/PLACEHOLDER_HOSTNAME/$CURRENT_HOST/g" /changehostname.c

	echo "Compiling changehostname.c"
    gcc -o /changehostname.o -c -fPIC -Wall /changehostname.c
    gcc -o /libchangehostname.so -shared -export-dynamic /changehostname.o -ldl

	echo "Done Compiling changehostname.c"
	which xvfb-run
    LD_PRELOAD=/libchangehostname.so xvfb-run --auto-servernum -s "-screen 0 1400x900x24" train
elif [ "$1" == 'serve' ]
then
    serve
fi
