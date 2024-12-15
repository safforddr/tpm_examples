TPM Examples

This directory contains four examples of using a TPM with tpm2-tools commands.

nv_pass.sh        - create an nv index which requires a password to read
nv_pcr.sh         - create an nv index which is locked to a pcr value
asymmetric.sh     - RSA encrypt/decrypt with no auth
policy_session.sh - RSA encrypt/decrypt with a PCR and owner password policy

Note: It is highly recommended to set the TPM's owner password, and 
      these scripts will set an owner password if one is not already set.
      You will want to remember the owner password.
      
tpm2-tools hints:
      - The TPM and tpm2-tools are stateful. Be sure to cleanup state
        (such as with tpm2_flushcontext) as needed. Cleanup after a demo
        is really important, and is demonstrated in these scripts.
        
      - Examples in the tpm2-tools man pages are simplified. For example,
        they frequently omit necessary associated authorization arguments.
        Some commands, such as tpm2_createprimary and tpm2_nvdefine always
        require owner auth.
        
      - Passwords normally should not be included in plaintext on the command
        lines. One way to avoid this is to use "file:-" in an authorization, which
        will prompt for password securely on the terminal window. For clarity
        of code, and simplicity in running the scripts, this is not done in
        the examples.
