#!/bin/bash

###################################################################
# Overview of the shell script:                                   #
#   1. Create and start the docker container if $1 is "start",    #
#      and use the specifid parameter "--config", "--input",      #
#      "--output" and "--proc", and generate the "{$proc}.ok",    #
#      "{$proc}.err", "{$proc}.containerid" file.                 #
#   2. Stop the container if $1 is "stop", and use the specifid   #
#      parameter "--output" and "--proc" to filter container by   #
#      name in "{$proc}.containerid" file.                        #
#   3. All containers will be removed at end of the script.        #
###################################################################


#---------------------------------------------------------------
#  Step 1. Init Variable.
#---------------------------------------------------------------

CONTAINER_NAME=$(head /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
echo $CONTAINER_NAME

DEFAULT_PROC="proc"
DEFAULT_INPUT_FOLDER="$PWD/00_input"
DEFAULT_OUTPUT_FOLDER="$PWD/01_output"
DEFAULT_CONFIG_FILE="$PWD/00_input/config.yaml"
DEFAULT_ARCH="hydcu"

PROC=""
INPUT_FOLDER=""
OUTPUT_FOLDER=""
UPLOAD_FOLDER=""
CONFIG_FILE=""
ARCH=""

#---------------------------------------------------------------
#  Step 2. Parse CMD and set Variable.
#---------------------------------------------------------------

index=1
for arg in "$@"; do  
    if [ "$arg" = "--input" ]; then
        index_next=$((index + 1))
        INPUT_FOLDER=${!index_next}
    fi
    if [ "$arg" = "--output" ]; then
        index_next=$((index + 1))
        OUTPUT_FOLDER=${!index_next}
    fi
    if [ "$arg" = "--upload" ]; then
        index_next=$((index + 1))
        UPLOAD_FOLDER=${!index_next}
    fi
    if [ "$arg" = "--config" ]; then
        index_next=$((index + 1))
        CONFIG_FILE=${!index_next}
    fi
    if [ "$arg" = "--proc" ]; then
        index_next=$((index + 1))
        PROC=${!index_next}
    fi
    if [ "$arg" = "--arch" ]; then
        index_next=$((index + 1))
        ARCH=${!index_next}
    fi
    index=$((index + 1))
done

#---------------------------------------------------------------
# Step 3. Set Default Variable if not specified.
#---------------------------------------------------------------

if [ "$INPUT_FOLDER" = "" ]; then
    echo "[INFO]Not specified: INPUT_FOLDER"
    INPUT_FOLDER=$DEFAULT_INPUT_FOLDER
    echo "Set Default INPUT_FOLDER: $DEFAULT_INPUT_FOLDER"
else
    echo "[INFO]INPUT_FOLDER: $INPUT_FOLDER"
fi

if [ "$OUTPUT_FOLDER" = "" ]; then
    echo "[INFO]Not specified: OUTPUT_FOLDER"
    OUTPUT_FOLDER=$DEFAULT_OUTPUT_FOLDER
    echo "Set Default OUTPUT_FOLDER: $DEFAULT_OUTPUT_FOLDER"
else
    echo "[INFO]OUTPUT_FOLDER: $OUTPUT_FOLDER"
fi

if [ "$CONFIG_FILE" = "" ]; then
    echo "[INFO]Not specified: CONFIG_FILE"
    CONFIG_FILE=$DEFAULT_CONFIG_FILE
    echo "Set Default CONFIG_FILE: $DEFAULT_CONFIG_FILE"
else
    echo "[INFO]CONFIG_FILE: $CONFIG_FILE"
fi

if [ "$PROC" = "" ]; then
    echo "[INFO]Not specified: PROC"
    PROC=$DEFAULT_PROC
    echo "Set Default PROC: $DEFAULT_PROC"
else
    echo "[INFO]PROC: $PROC"
fi

if [ "$ARCH" = "" ]; then
    echo "[INFO]Not specified: ARCH"
    ARCH=$DEFAULT_ARCH
    echo "Set Default ARCH: $DEFAULT_ARCH"
else
    echo "[INFO]ARCH: $ARCH"
fi

#---------------------------------------------------------------
# Step 4. Check Volumes for docker.
#---------------------------------------------------------------

if [ "$1" = "start" ]; then
    # is exist INPUT_FOLDER
    if [ -d "$INPUT_FOLDER" ]; then
        echo "Already exist INPUT_FOLDER: $INPUT_FOLDER"
    else
        echo "[ERROR]Not exist INPUT_FOLDER: $INPUT_FOLDER"
        touch "$OUTPUT_FOLDER/$PROC.err"
        exit 1
    fi
fi

# is exist OUTPUT_FOLDER
if [ -d "$OUTPUT_FOLDER" ]; then
    echo "Already exist OUTPUT_FOLDER: $OUTPUT_FOLDER"
    # delete success/fail flag file before execute docker container
    if [ "$1" = "start" ]; then
        if [ -e "$OUTPUT_FOLDER/$PROC.ok" ]; then
            rm $OUTPUT_FOLDER/$PROC.ok
        fi
        if [ -e "$OUTPUT_FOLDER/$PROC.err" ]; then
            rm $OUTPUT_FOLDER/$PROC.err
        fi
    fi
else
    mkdir $OUTPUT_FOLDER
    echo "Created: $OUTPUT_FOLDER"
fi

# if exists UPLOAD_FOLDER and yolov5_u.prototxt
PROTOTXTFILE=$(find ${INPUT_FOLDER} -name yolov5_u.prototxt)
if [ -d "$UPLOAD_FOLDER" -a -f "$PROTOTXTFILE" ]; then
    cp -rf $PROTOTXTFILE $UPLOAD_FOLDER/
fi

# Save CONTAINER_NAME for Stopping and Remove container
if [ "$1" = "start" ]; then
    echo $CONTAINER_NAME > $OUTPUT_FOLDER/$PROC.containerid
fi
#---------------------------------------------------------------
# Step 5. Set env variable for docker.
#---------------------------------------------------------------

export CONTAINER_NAME=$CONTAINER_NAME
export PROC=$PROC
export INPUT_FOLDER=$INPUT_FOLDER
export OUTPUT_FOLDER=$OUTPUT_FOLDER
export CONFIG_FILE=$CONFIG_FILE

#---------------------------------------------------------------
# Step 6. Create/Stop docker container.
#---------------------------------------------------------------

if [ "$1" = "start" ]; then
    echo "Creating container $CONTAINER_NAME ..."
    docker-compose -f docker/00_train/docker-compose-$ARCH.yml -p $CONTAINER_NAME up # -d
elif [ "$1" = "stop" ]; then
    CONTAINER_NAME=$(cat "$OUTPUT_FOLDER/$PROC.containerid")
    export CONTAINER_NAME=$CONTAINER_NAME
    echo "Stopping container $CONTAINER_NAME ... "
    docker-compose -f docker/00_train/docker-compose-$ARCH.yml -p $CONTAINER_NAME down
    # docker rm -f $(docker ps -a |  grep "$CONTAINER_NAME*"  | awk '{print $1}')
    echo "Stopped container: $CONTAINER_NAME"
else
    echo "[ERROR]Unknow parameter: $1"
fi

#---------------------------------------------------------------
# Step 7. Generate success/fail flag file.
#---------------------------------------------------------------

if [ "$1" = "start" ]; then
    # Waitting for container exit
    docker container wait $CONTAINER_NAME
    # Get container exit code
    exit_status=$(docker inspect -f '{{.State.ExitCode}}' $CONTAINER_NAME)

    # is empty
    if [ -z "$exit_status" ]; then
        touch "$OUTPUT_FOLDER/$PROC.err"
    else
        if [ $exit_status -eq 0 ]; then
            touch "$OUTPUT_FOLDER/$PROC.ok"
        else
            touch "$OUTPUT_FOLDER/$PROC.err"
        fi
    fi

    echo "Docker container $CONTAINER_NAME exit with code $exit_status."
fi

#---------------------------------------------------------------
# Step 8. Remove container.
#---------------------------------------------------------------

# Remove container if exist.
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    docker rm -f $(docker ps -a |  grep "$CONTAINER_NAME*"  | awk '{print $1}')
    echo "Removed container: $CONTAINER_NAME"
fi
