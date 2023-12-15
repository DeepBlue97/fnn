#!/bin/bash

###################################################################
# Overview of the shell script:                                   #
#   1. Create and start the docker container if $1 is "start".    #
#   2. Stop the container if $1 is "stop".                        #
#   3. All containers will be removed at end of the script.       #
###################################################################


#---------------------------------------------------------------
#  Step 1. Init Variable.
#---------------------------------------------------------------

CONTAINER_NAME=$(head /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
echo $CONTAINER_NAME

DEFAULT_CONFIG_FILE="$PWD/00_input/config.yaml"
DEFAULT_WEIGHT_FILE="$pwd/01_trained_model/exp/weights/best.pt"
DEFAULT_DATASET_FOLDER="$pwd/00_input/datasets/custom_detection"
DEFAULT_OUTPUT_FOLDER="$PWD/02_quanted_model"
DEFAULT_PROC="proc"

CONFIG_FILE=""
WEIGHT_FILE=""
DATASET_FOLDER=""
OUTPUT_FOLDER=""
PROC=""

#---------------------------------------------------------------
#  Step 2. Parse CMD and set Variable.
#---------------------------------------------------------------

index=1
for arg in "$@"; do

    if [ "$arg" = "--config" ]; then
        index_next=$((index + 1))
        CONFIG_FILE=${!index_next}
    fi
    if [ "$arg" = "--weight" ]; then
        index_next=$((index + 1))
        WEIGHT_FILE=${!index_next}
    fi
    if [ "$arg" = "--dataset" ]; then
        index_next=$((index + 1))
        DATASET_FOLDER=${!index_next}
    fi
    if [ "$arg" = "--output" ]; then
        index_next=$((index + 1))
        OUTPUT_FOLDER=${!index_next}
    fi
    if [ "$arg" = "--proc" ]; then
        index_next=$((index + 1))
        PROC=${!index_next}
    fi

    index=$((index + 1))
done

#---------------------------------------------------------------
# Step 3. Set Default Variable if not specified.
#---------------------------------------------------------------

if [ "$CONFIG_FILE" = "" ]; then
    echo "[INFO]Not specified: CONFIG_FILE"
    CONFIG_FILE=$DEFAULT_CONFIG_FILE
    echo "Set Default CONFIG_FILE: $DEFAULT_CONFIG_FILE"
else
    echo "[INFO]CONFIG_FILE: $CONFIG_FILE"
fi

if [ "$WEIGHT_FILE" = "" ]; then
    echo "[INFO]Not specified: WEIGHT_FILE"
    WEIGHT_FILE=$DEFAULT_WEIGHT_FILE
    echo "Set Default WEIGHT_FILE: $DEFAULT_WEIGHT_FILE"
else
    echo "[INFO]WEIGHT_FILE: $WEIGHT_FILE"
fi

if [ "$DATASET_FOLDER" = "" ]; then
    echo "[INFO]Not specified: DATASET_FOLDER"
    DATASET_FOLDER=$DEFAULT_DATASET_FOLDER
    echo "Set Default DATASET_FOLDER: $DEFAULT_DATASET_FOLDER"
else
    echo "[INFO]DATASET_FOLDER: $DATASET_FOLDER"
fi

if [ "$OUTPUT_FOLDER" = "" ]; then
    echo "[INFO]Not specified: OUTPUT_FOLDER"
    OUTPUT_FOLDER=$DEFAULT_OUTPUT_FOLDER
    echo "Set Default OUTPUT_FOLDER: $DEFAULT_OUTPUT_FOLDER"
else
    echo "[INFO]OUTPUT_FOLDER: $OUTPUT_FOLDER"
fi

if [ "$PROC" = "" ]; then
    echo "[INFO]Not specified: PROC"
    PROC=$DEFAULT_PROC
    echo "Set Default PROC: $DEFAULT_PROC"
else
    echo "[INFO]PROC: $PROC"
fi

#---------------------------------------------------------------
# Step 4. Check Volumes for docker.
#---------------------------------------------------------------

if [ "$1" = "start" ]; then
    # is exist CONFIG_FILE
    if [ -e "$CONFIG_FILE" ]; then
        echo "Already exist CONFIG_FILE: $CONFIG_FILE"
    else
        echo "[ERROR]Not exist CONFIG_FILE: $CONFIG_FILE"
        touch "$OUTPUT_FOLDER/$PROC.err"
        exit 1
    fi
    # is exist WEIGHT_FILE
    if [ -e "$WEIGHT_FILE" ]; then
        echo "Already exist WEIGHT_FILE: $WEIGHT_FILE"
    else
        echo "[ERROR]Not exist WEIGHT_FILE: $WEIGHT_FILE"
        touch "$OUTPUT_FOLDER/$PROC.err"
        exit 1
    fi
    # is exist DATASET_FOLDER
    if [ -d "$DATASET_FOLDER" ]; then
        echo "Already exist DATASET_FOLDER: $DATASET_FOLDER"
    else
        echo "[ERROR]Not exist DATASET_FOLDER: $DATASET_FOLDER"
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

# Save CONTAINER_NAME for Stopping and Remove container
if [ "$1" = "start" ]; then
    echo $CONTAINER_NAME > $OUTPUT_FOLDER/$PROC.containerid
fi

#---------------------------------------------------------------
# Step 5. Set env variable for docker.
#---------------------------------------------------------------

export CONTAINER_NAME=$CONTAINER_NAME
export CONFIG_FILE=$CONFIG_FILE
export WEIGHT_FILE=$WEIGHT_FILE
export DATASET_FOLDER=$DATASET_FOLDER
export OUTPUT_FOLDER=$OUTPUT_FOLDER
export PROC=$PROC

#---------------------------------------------------------------
# Step 6. Create/Stop docker container.
#---------------------------------------------------------------

if [ "$1" = "start" ]; then
    echo "Creating container $CONTAINER_NAME ..."
    docker-compose -f docker/01_quant/docker-compose.yml -p $CONTAINER_NAME up # -d
elif [ "$1" = "stop" ]; then
    CONTAINER_NAME=$(cat "$OUTPUT_FOLDER/$PROC.containerid")
    export CONTAINER_NAME=$CONTAINER_NAME
    echo "Stopping container $CONTAINER_NAME ... "
    docker-compose -f docker/01_quant/docker-compose.yml -p $CONTAINER_NAME down
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
