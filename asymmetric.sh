#!/bin/sh

tpm2_flushcontext -t

# Get existing TPM owner password, or set new one
if tpm2_getcap properties-variable| grep ownerAuthSet|grep -q 1 ; then
        IFS= read -r -s -p 'Enter existing TPM owner password: ' OPW
        echo
else
        echo 'Your TPM has no owner password. Enter a new one: '
        tpm2_changeauth -c owner $OPW
        echo
fi

echo "Creating primary."
tpm2_createprimary -c primary.ctx -P $OPW
echo
echo "Create asymmetric encryption key."
tpm2_create -C primary.ctx -Grsa1024 -u tpmkey.pub -r tpmkey.priv
echo
echo "Load encryption key."
tpm2_load -C primary.ctx -u tpmkey.pub -r tpmkey.priv -c tpmkey.ctx

echo ‘This is a secret.’ > data.txt
echo
echo "Encrypt the data file."
tpm2_rsaencrypt -c tpmkey.ctx -o data.enc data.txt 
echo
echo "Decrypt the data file."
tpm2_rsadecrypt -c tpmkey.ctx data.enc 
echo
echo "Cleaning up."
rm -f primary.ctx tpmkey.pub tpmkey.priv tpmkey.ctx data.enc data.txt
tpm2_flushcontext -t
