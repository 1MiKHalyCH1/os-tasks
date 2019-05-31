#!/bin/bash
source ./utils.sh

MY_CHAR="X"
OP_CHAR="O"
MY_PORT=7703
OP_PORT=7704

function main {
    draw_board
    while true;
    do
        make_move
        if check_win; then exit; fi

        wait_turn
        if check_win; then exit; fi
    done
}

main