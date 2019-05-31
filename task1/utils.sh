STATE='012345678'
BORDER_COLOR=`tput setaf 2`
CELL_EMPTY_COLOR=`tput setaf 6`
CELL_FILLED_COLOR=`tput setaf 1`

function draw_board {
    clear
    echo 'Board:'
    echo ${BORDER_COLOR}'┏━━━┳━━━┳━━━┓'
    for (( i=0; i<3; i++ ));
    do
        echo -n '┃'
        for (( j=0; j<3; j++ ));
        do
            s=${STATE:3*i+j:1}
            if [[ ! $s =~ [0-8] ]]
                then echo -n ${CELL_EMPTY_COLOR} $s ${BORDER_COLOR}'┃'
                else echo -n ${CELL_FILLED_COLOR} $s ${BORDER_COLOR}'┃'
            fi
        done
        if [[ $i != 2 ]];
            then echo -e '\n┣━━━╋━━━╋━━━┫'
        fi
    done
    echo -e '\n┗━━━┻━━━┻━━━┛'
    tput sgr0
}

function wait_turn {
    turn=`nc -l 0.0.0.0 -p $MY_PORT -q 0`
    fill_cell $turn $OP_CHAR
    draw_board
}

function send_turn {
    echo -n $1 | nc 0.0.0.0 $OP_PORT
}

function fill_cell {
    pos=$1
    STATE=${STATE:0:pos}${2}${STATE:pos+1}
}

function make_move {
    read -n1 -p 'Enter cell: ' cell
    while [[ ! $cell =~ [0-8] ]] || [[ ! ${STATE:cell:1} =~ [0-8] ]];
    do
        echo -en '\r'
        read -n1 -p 'Wrong! Enter cell: ' cell
    done
    fill_cell $cell $MY_CHAR
    send_turn $cell
    draw_board
}

function check_win {
    win_lines='012-345-678-036-147-258-048-246'
    for (( i=1; i<9; i++ ));
    do
        line=$(echo $win_lines | cut -d'-' -f $i)
        c1=${line:0:1};c1=${STATE:c1:1}
        c2=${line:1:1};c2=${STATE:c2:1}
        c3=${line:2:1};c3=${STATE:c3:1}
        if [[ ! $c1 =~ [0-8] ]] && [[ $c1 == $c2 ]] && [[ $c1 == $c3 ]]
            then
            if [[ $c1 == $MY_CHAR ]]
                then echo $MY_CHAR' wins'
                else echo $OP_CHAR' wins'
            fi
            return 0
        fi
    done

    for (( i=0; i<9; i++ ));
    do
        if [[ ! 'OX' =~ ${STATE:i:1} ]];
            then return 1
        fi
    done
    echo 'Draw'
    return 0
}