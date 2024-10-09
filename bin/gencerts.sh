#!/bin/bash

SUBJ='/C=US/ST=North Carolina/L=Raleigh'
SUBJ+='/O=Red Hat Inc./OU=RHTPA'

TRUST_ANCHOR='rootCA'

CERTS=(
    'bombastic-api-tls'
    'collector-osv-tls'
    'collector-osv-tls-client'
    'collectorist-api-tls'
    'collectorist-api-tls-csub'
    'guac-collectsub-tls'
    'guac-graphql-tls'
    'nginx-tls'
    'spog-api-tls'
    'vexination-api-tls'
)

CERT_DIR='/tmp/rhtpa/certs'
mkdir -p "$CERT_DIR"

# Trust Anchor
openssl genpkey -algorithm RSA -out "${CERT_DIR}/${TRUST_ANCHOR}.key" -aes256 -pass pass:passwd123 -outform PEM -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -nodes -key "${CERT_DIR}/${TRUST_ANCHOR}.key" -sha256 -days 3650 -out "${CERT_DIR}/${TRUST_ANCHOR}.crt" -passin pass:passwd123 -subj "${SUBJ}/CN=RTHTPA Example Root CA"

for certname in "${CERTS[@]}"; do
    rm -f "${CERT_DIR}/${certname}.key" "${CERT_DIR}/${certname}.crt"
    
    # Create the private key
    openssl genpkey -algorithm RSA -out "${CERT_DIR}/${certname}.key" -aes256 -pass pass:passwd123 -outform PEM -pkeyopt rsa_keygen_bits:2048

    # # Create the CSR
    openssl req -new -key "${CERT_DIR}/${certname}.key" -out "${CERT_DIR}/${certname}.csr" -passin pass:passwd123 -subj "${SUBJ}/CN=${certname}"

    # # Sign the CSR with the CA
    openssl x509 -req -in "${CERT_DIR}/${certname}.csr" -CA "${CERT_DIR}/${TRUST_ANCHOR}.crt" -CAkey "${CERT_DIR}/${TRUST_ANCHOR}.key" -CAcreateserial -out "${CERT_DIR}/${certname}.crt" -days 825 -sha256 -passin pass:passwd123

    # Remove the CSR file
    rm "${CERT_DIR}/${certname}.csr"
done

# Remove the CA serial file
rm "${CERT_DIR}/${TRUST_ANCHOR}.srl"
