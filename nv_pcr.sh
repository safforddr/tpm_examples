#!/bin/sh
# NV PCR policy

NVINDEX=0x1500016

# Get existing TPM owner password, or set new one
if tpm2_getcap properties-variable| grep ownerAuthSet|grep -q 1 ; then
        IFS= read -r -s -p 'Enter existing TPM owner password: ' OPW
        echo
else
        echo 'Your TPM has no owner password. Enter a new one: '
        tpm2_changeauth -c owner $OPW
        echo
fi

tpm2_flushcontext -t

echo "Existing PCR-23"
tpm2_pcrread sha256:23
echo

echo "Creating PCR Policy."
tpm2_createpolicy --policy-pcr -l sha256:23 -L measured.policy
echo

echo "Defining NV index with PCR policy."
tpm2_nvdefine $NVINDEX -C o -s 32 -L measured.policy -a "policyread|policywrite" -P $OPW

echo -n "This is a secret." > secret.txt 
echo

echo "Write secret data to NV index."
tpm2_nvwrite $NVINDEX -P pcr:sha256:23 -i secret.txt
echo

echo "Reading back NV index with same PCR."
tpm2_nvread -P pcr:sha256:23 -s 17 $NVINDEX
echo
echo

echo "Extending PCR."
tpm2_pcrextend 23:sha256=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f23cd32812f4850b878ae4944c

echo "PCR 23 is now:"
tpm2_pcrread sha256:23
echo

echo "Trying read again."
tpm2_nvread -P pcr:sha256:23 $NVINDEX

echo "Cleaning up."
tpm2_nvundefine $NVINDEX -C o -P $OPW
tpm2_flushcontext -t
rm -f measured.policy secret.txt
