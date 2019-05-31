#!/bin/bash
source ./utils.sh

MY_CHAR="O"
OP_CHAR="X"
MY_PORT=7704
OP_PORT=7703

function main {
    draw_board
    while true;
    do
        wait_turn
        if check_win; then exit; fi

        make_move
        if check_win; then exit; fi
    done
}

main