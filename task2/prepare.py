from os import urandom
from sys import argv

def get_random_bytes(k): return bytes([x for x in urandom(k) if x])

if __name__ == "__main__":
    k = 1000
    with open("sparse-file", "wb") as f:
        f.write(get_random_bytes(k))
        f.truncate(int(argv[1]))
        f.seek(0, 2)
        f.write(get_random_bytes(k))
        f.flush()