#!/bin/bash

if [ -z "$1" ]; then
  echo "Please enter a name for your keypair"
  exit 1
fi

# Read the public key from the provided file
keyName="$1"

openssl ecparam -genkey -name secp256k1 -out $keyName-private.pem
openssl ec -in $keyName-private.pem -text -noout | grep priv -A 3 | tail -n +2 | tr -d "\n[:space:]" | sed 's/^00//' > $keyName-private.hex
openssl ec -in $keyName-private.pem -pubout -outform DER | tail -c 65 | xxd -p -c 65 > $keyName-public.hex
rm $keyName-private.pem
cat $keyName-public.hex | xxd -r -p | openssl dgst -sha3-256 | awk '{print "0x"substr($2,length($2)-39)}' > $keyName-address.hex
