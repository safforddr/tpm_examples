#!/bin/sh
NVIndex=0x1500020
DATFILE="data.txt"
echo "Hello World" > $DATFILE

# Get existing TPM owner password, or set new one
if tpm2_getcap properties-variable| grep ownerAuthSet|grep -q 1 ; then
        IFS= read -r -s -p 'Enter existing TPM owner password: ' OPW
        echo
else
        echo 'Your TPM has no owner password. Enter a new one: '
        tpm2_changeauth -c owner $OPW
        echo
fi

echo "Defining index with owner password."
tpm2_nvdefine $NVIndex -C o -s 32 -a "ownerread|ownerwrite" -P $OPW

echo "Writing data file to index."
tpm2_nvwrite -C o -i $DATFILE -P $OPW $NVIndex 
echo
echo "Trying to read without owner password."
tpm2_nvread -C o -s 11 $NVIndex
echo
echo "Reading data with owner password."
tpm2_nvread -C o -s 11 -P $OPW $NVIndex 
echo " "

echo "Listing nv indicies."
tpm2_getcap handles-nv-index

echo "Removing index and data file"
tpm2_nvundefine $NVIndex -C o -P $OPW
rm -f $DATFILE
