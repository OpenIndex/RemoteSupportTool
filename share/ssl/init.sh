#!/usr/bin/env bash
#
# Copyright 2015-2018 OpenIndex.de
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

KEYTOOL="keytool"
ALIAS="support"
VALIDITY=9999

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KEYSTORE="$DIR/keystore.jks"
TRUSTSTORE="$DIR/truststore.jks"
CERT="$DIR/$ALIAS.crt"

KEYSTORE_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"
TRUSTSTORE_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"

set -e

echo ""
echo "--------------------------------------------------------"
echo " Generating key pair..."
echo "--------------------------------------------------------"
echo ""

rm -f "$KEYSTORE"
"$KEYTOOL" \
    -genkeypair \
    -keyalg RSA \
    -keysize 4096 \
    -alias "$ALIAS" \
    -validity "$VALIDITY" \
    -keystore "$KEYSTORE" \
    -keypass "$KEYSTORE_PASSWORD" \
    -storepass "$KEYSTORE_PASSWORD"

echo ""
echo "--------------------------------------------------------"
echo " Exporting certificate..."
echo "--------------------------------------------------------"
echo ""

rm -f "$CERT"
"$KEYTOOL" \
    -export \
    -alias "$ALIAS" \
    -file "$CERT" \
    -keystore "$KEYSTORE" \
    -storepass "$KEYSTORE_PASSWORD"

echo ""
echo "--------------------------------------------------------"
echo " Adding certificate to truststore..."
echo "--------------------------------------------------------"
echo ""

rm -f "$TRUSTSTORE"
"$KEYTOOL" \
    -import \
    -v \
    -alias "$ALIAS" \
    -file "$CERT" \
    -keystore "$TRUSTSTORE" \
    -keypass "$TRUSTSTORE_PASSWORD" \
    -storepass "$TRUSTSTORE_PASSWORD"

echo ""
echo "--------------------------------------------------------"
echo ""
echo "The keystore for the client application is stored at"
echo ""
echo " $KEYSTORE"
echo ""
echo "and protected with the password"
echo ""
echo " $KEYSTORE_PASSWORD"

echo ""
echo "--------------------------------------------------------"
echo ""
echo "The truststore for the server application is stored at:"
echo ""
echo " $TRUSTSTORE"
echo ""
echo "and protected with the password"
echo ""
echo " $TRUSTSTORE_PASSWORD"
echo ""

echo "$KEYSTORE_PASSWORD" > "$KEYSTORE.txt"
echo "$TRUSTSTORE_PASSWORD" > "$TRUSTSTORE.txt"
