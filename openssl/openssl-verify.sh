#!/bin/bash

REQUIRED="OpenSSL 3.0.7 1 Nov 2022"
OUTPUT=`python -c \
    "import cryptography.hazmat.backends.openssl.backend as C; print(C.openssl_version_text())"`
if [[ $OUTPUT !=  $REQUIRED ]]; then
    echo "OpenSSL version mismatch for cryptography package"
    echo "Got $OUTPUT, required $REQUIRED"
    exit 1
fi