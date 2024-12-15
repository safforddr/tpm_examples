#!/bin/sh
# demonstrate a policy session with pcr and password auth

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
echo "Create Policy."
tpm2_startauthsession -S session.dat
tpm2_policypcr -S session.dat -l sha256:23 -L policy.dat
tpm2_policysecret -S session.dat -c o -L policy.dat "$OPW"
tpm2_flushcontext session.dat

echo "Create asymmetric encryption key."
tpm2_create -C primary.ctx -L policy.dat -Grsa1024 -u tpmkey.pub -r tpmkey.priv
echo

# loading the key does not require the policy
echo "Load encryption key."
tpm2_load -C primary.ctx -u tpmkey.pub -r tpmkey.priv -c tpmkey.ctx

echo ‘This is a secret.’ > data.txt
echo

# encryption uses only the public key, and does not require policy
echo "Encrypt the data file."
tpm2_rsaencrypt -c tpmkey.ctx -o data.enc data.txt 
echo

# decryption requires the policy
echo "Decrypt the data file."
tpm2_startauthsession --policy-session -S session.dat 
tpm2_policypcr -S session.dat -l sha256:23 -L policy.dat
tpm2_policysecret -S session.dat -c o -L policy.dat "$OPW"
tpm2_rsadecrypt -c tpmkey.ctx -p "session:session.dat" data.enc 
tpm2_flushcontext session.dat
echo
echo "Cleaning up."
rm -f primary.ctx tpmkey.pub tpmkey.priv tpmkey.ctx data.enc data.txt policy.dat session.dat
tpm2_flushcontext -t

	
