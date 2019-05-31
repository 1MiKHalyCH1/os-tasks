#! /bin/bash

if [ -z "$1" ]
    then
    echo "using: './test.sh <size of zero-part>'"
    exit
fi

echo "[+] Generating "${1}" zeros in sparse-file"
python3 prepare.py $1

echo -e "Sparse file pseudo size:\t" $(du -h -B1 --apparent-size sparse-file | cut -f1)
echo -e "Sparse file real size:\t\t" $(du -h -B1 sparse-file | cut -f1)

echo "[+] Gziping"
gzip -c sparse-file > sparse-file.gz

echo "[+] Building parser"
./build.sh

echo "[+] Ungziping with parser"
gzip -cd sparse-file.gz | ./parser res

echo -e "Ungziped file pseudo size:\t" $(du -h -B1 --apparent-size res | cut -f1)
echo -e "Ungziped file real size:\t" $(du -h -B1 res | cut -f1)

echo "[+] SHA256 hashsums"
sha256sum sparse-file res
rm res parser sparse-file*