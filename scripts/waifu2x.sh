#!/bin/bash

waifu () {
    if [[ $# -eq 0 ]]; then
        cat << EOF
Usage: waifu [OPTIONS] FILE1 [FILE2 ...]
Options:
    -d          dry run, just print out the commands to exec.
    -n<1|2>     noise reduction level
    -s<NUM>     scale ratio; default: -s4
    -j<NUM>     numbers of threads launching at the same time; default: -j4
    --          terminate options list
EOF
        waifu2x --version
        waifu2x --list-processor
        return 0
    fi

    local DRYRUN=''
    local SCALE=''
    local NOISE=''
    local JOBS=''

    while [[ $# -gt 0 ]]; do
        opt="$1"

        case $opt in
            --) # terminate options list
                shift
                break
            ;;
            -d) # dry run
                DRYRUN="yes"
            ;;
            -s*) # scale ratio
                SCALE=${opt:2}
            ;;
            -n*) # noise reduction level
                NOISE=${opt:2}
            ;;
            -j*) # concurrent jobs
                JOBS=${opt:2}
            ;;
            *) # no more options
                break
            ;;
        esac
        shift
    done

    if [[ $# -eq 0 ]]; then
        echo no input file was specified, exiting.
        return 1
    fi

    local CONFIG=""
    local POSTFIX="_waifu"

    if [[ -n "$SCALE" ]]; then
        CONFIG+=" --scale_ratio $SCALE"
        POSTFIX+="_s$SCALE"
    else
        # defaults to 4x scale
        CONFIG+=" --scale_ratio 4"
        POSTFIX+="_s4"
    fi

    if [[ -n "$NOISE" ]]; then
        CONFIG+=" --noise_level $NOISE"
        POSTFIX+="_n$NOISE"
    else
        POSTFIX+="_n0"
    fi

    if [[ -n "$JOBS" ]]; then
        CONFIG+=" --jobs $JOBS"
    else
        # defaults to 4 jobs
        CONFIG+=" --jobs 4"
    fi

    for f in "$@"; do
        local NAME=$(basename -- "$f")
        local EXT="${NAME##*.}"
        local NAME="${NAME%.*}"
        if [[ -n "$DRYRUN" ]]; then
            echo waifu2x $CONFIG -i "$f" -o "$NAME$POSTFIX.$EXT"
        else
            waifu2x $CONFIG -i "$f" -o "$NAME$POSTFIX.$EXT"
        fi
    done
}
