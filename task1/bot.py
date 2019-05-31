from pwn import *
from math import inf
from os import system
from time import sleep

CORNERS = [0, 2, 6, 8]
LINES = [(0,1,2),(3,4,5),(6,7,8),(0,3,6),(1,4,7),(2,5,8),(0,4,8),(2,4,6)]


def read_board(r):
    r.recvuntil('Board:\n')
    board = []
    for _ in range(3):
        r.recvline()
        line = r.recvline(keepends=False)
        # print(line.decode())
        board.extend(line.decode().split(' ')[1:-1:2])
    # print(r.recvline().decode())
    return board

def draw_board(board):
    system('clear')
    print('┏━━━┳━━━┳━━━┓')
    print('┃ '+' ┃ '.join(board[:3]) +' ┃')
    print('┣━━━╋━━━╋━━━┫')
    print('┃ '+' ┃ '.join(board[3:6]) +' ┃')
    print('┣━━━╋━━━╋━━━┫')
    print('┃ '+' ┃ '.join(board[6:9]) +' ┃')
    print('┗━━━┻━━━┻━━━┛')
    

def valid_moves(board):
    return [int(x) for x in board if x not in "XO"]

def is_win(board, player):
    return (player, player, player) in ((board[x[0]], board[x[1]], board[x[2]]) for x in LINES)

def game_over(board):
    return is_win(board, 'O') or is_win(board, 'X') or not valid_moves(board)

def calc_score(board):
    if is_win(board, 'O'): return 1
    elif is_win(board, 'X'): return -1
    else: return 0

def minimax(board, depth, player):
    best_move, best_score = None, -inf if player == 'O' else inf

    if depth == 0 or game_over(board):
        return best_move, calc_score(board)

    for cell in valid_moves(board):
        board[cell] = player
        move, score = minimax(board, depth-1, 'O' if player == 'X' else 'X')
        board[cell] = str(cell)
        move = cell

        if player == 'O':
            if score > best_score:
                best_score = score
                best_move = move
        else:
            if score < best_score:
                best_score = score
                best_move = move
    
    return best_move, best_score

def make_move(board):
    return str(minimax(board, len(valid_moves(board)), 'O')[0])

if __name__ == "__main__":
    r = process("./client_o.sh")
    read_board(r)

    while True:
        board = read_board(r)
        draw_board(board)
        sleep(1)
        try:
            r.sendline(make_move(board))
        except Exception:
            break
        if not game_over(board):
            board = read_board(r)
            draw_board(board)
            if game_over(board):
                break