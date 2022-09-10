KEYLEN=2048
ORG=peakbook
COUNTRY=JP
STATE=Tokyo

# Fully Qualified Domain Name
COMNAME_CA=peakbook
COMNAME_SRV=localhost

# how long till expiry of a signed certificate
DAYS=3650  

CA_KEY=ca.key
CA_CSR=ca.csr
CA_CRT=ca.crt

SRV_KEY=srv.key
SRV_CSR=srv.csr
SRV_CRT=srv.crt
SRV_PEM=srv.pem

# set Subjective Alternative Name (SAN)
SAN=subjectAltName = DNS:localhost, IP:127.0.0.1

all: help

gen: verify ## generate self-signed certificates

gen_ca_cert: ## generate a local CA certificate
	# generate a private key for Certificate Authority (CA)
	openssl genrsa -out $(CA_KEY) $(KEYLEN)
	# generate a Certificate Signing Request (CSR) for CA 
	openssl req -new -key $(CA_KEY) -out $(CA_CSR) -subj "/C=$(COUNTRY)/ST=$(STATE)/O=$(ORG)/CN=$(COMNAME_CA)"
	# sign the CSR with the private key 
	openssl x509 -req -days $(DAYS) -signkey $(CA_KEY) -in $(CA_CSR) -out $(CA_CRT)

gen_srv_cert: gen_ca_cert# # generate a server certificate signed by local CA
	# generate a private key for a server 
	openssl genrsa -out $(SRV_KEY) $(KEYLEN)
	# generate a CSR for the server
	openssl req -new -key $(SRV_KEY) -out $(SRV_CSR) -subj "/C=$(COUNTRY)/ST=$(STATE)/O=$(ORG)/CN=$(COMNAME_SRV)"
	# sign the server CSR by local CA
	openssl x509 -req -days $(DAYS) -CA $(CA_CRT) -CAkey $(CA_KEY) -CAcreateserial -in $(SRV_CSR) -extfile <(printf "$(SAN)") -out $(SRV_CRT)
  
gen_srv_pem: gen_srv_cert  ## generate PEM for the server
	cat $(SRV_KEY) $(SRV_CRT) $(CA_CRT) > $(SRV_PEM)

verify: gen_srv_pem ## verify the server CRT by the local CA CRT
	openssl verify -CAfile $(CA_CRT) $(SRV_CRT)

help: ## this help
	-@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: all gen gen_ca_cert gen_server_cert verify help
