ultimate = ultimate$(ultimate_serial)
ultimatedirectory = output/$(ultimate)

ultimate_infrastructure_directories = \
	$(ultimatedirectory)/private/keys \
	$(ultimatedirectory)/public/certs \
	$(ultimatedirectory)/public/crls

ultimate_infrastructure_files = \
	$(ultimatedirectory)/private/database.db \
	$(ultimatedirectory)/private/serial \
	$(ultimatedirectory)/private/crlnumber \
	$(ultimatedirectory)/private/.rand

ultimate_tls_keys = \
	$(ultimatedirectory)/private/keys/$(ultimate).key.pem \
	$(ultimatedirectory)/private/keys/$(ultimate).key \
	$(ultimatedirectory)/private/keys/$(ultimate).key.der \
	$(ultimatedirectory)/private/keys/$(ultimate).key.pfx

ultimate_tls_certs = \
	$(ultimatedirectory)/public/certs/$(ultimate).cert.pem \
	$(ultimatedirectory)/public/certs/$(ultimate).cer \
	$(ultimatedirectory)/public/certs/$(ultimate).crt \
	$(ultimatedirectory)/public/certs/$(ultimate).cert.der \
	$(ultimatedirectory)/public/certs/$(ultimate).p7b \
	$(ultimatedirectory)/public/certs/$(ultimate).p7r \
	$(ultimatedirectory)/public/certs/$(ultimate).spc \
	$(ultimatedirectory)/public/certs/$(ultimate).cert.pfx

ultimate_tls = $(ultimate_tls_keys) $(ultimate_tls_certs)

#
# Infrastructure Generation
#

./configuration/ultimate.config : ./configuration/ultimate.config.template
	sed \
	-e 's/ULTIMATE_SERIAL/$(ultimate_serial)/g' \
	-e 's/PENULTIMATE_CRL_CONFIG//g' \
	-e 's/ORGANIZATION_NAME/$(organization_name)/g' \
	< ./configuration/ultimate.config.template \
	> ./configuration/ultimate.config

#
# TLS Key Generation
#

ultimate_tls_key : $(ultimate_tls_keys)

$(ultimatedirectory)/private/keys/$(ultimate).key.pem :
	mkdir -p $(ultimatedirectory)/private/keys
	openssl genrsa \
	-out $(ultimatedirectory)/private/keys/$(ultimate).key.pem 4096

$(ultimatedirectory)/private/keys/$(ultimate).key : $(ultimatedirectory)/private/keys/$(ultimate).key.pem
	mkdir -p $(ultimatedirectory)/private/keys
	cp \
	$(ultimatedirectory)/private/keys/$(ultimate).key.pem \
	$(ultimatedirectory)/private/keys/$(ultimate).key

$(ultimatedirectory)/private/keys/$(ultimate).key.der : $(ultimatedirectory)/private/keys/$(ultimate).key
	mkdir -p $(ultimatedirectory)/private/keys
	openssl rsa \
	-in $(ultimatedirectory)/private/keys/$(ultimate).key \
	-outform DER \
	-out $(ultimatedirectory)/private/keys/$(ultimate).key.der

$(ultimatedirectory)/private/keys/$(ultimate).key.pfx : $(ultimatedirectory)/private/keys/$(ultimate).key
	mkdir -p $(ultimatedirectory)/private/keys
	openssl pkcs12 \
	-export \
	-nocerts \
	-inkey $(ultimatedirectory)/private/keys/$(ultimate).key \
	-out $(ultimatedirectory)/private/keys/$(ultimate).key.pfx \
	-passout pass:

#
# TLS Certificate Generation
#

ultimate_tls_cert : $(ultimate_tls_certs)

$(ultimatedirectory)/public/certs/$(ultimate).cert.pem : $(ultimatedirectory)/private/keys/$(ultimate).key ./configuration/ultimate.config
	mkdir -p $(ultimatedirectory)/private/keys
	mkdir -p $(ultimatedirectory)/public/certs
	touch $(ultimatedirectory)/private/.rand
	dd if=/dev/urandom of=$(ultimatedirectory)/private/.rand bs=256 count=1
	echo 01 > $(ultimatedirectory)/private/serial
	echo 01 > $(ultimatedirectory)/private/crlnumber
	openssl req \
	-new \
	-x509 \
	-days 7300 \
	-config ./configuration/ultimate.config \
	-extensions ultimate \
	-key $(ultimatedirectory)/private/keys/$(ultimate).key \
	-out $(ultimatedirectory)/public/certs/$(ultimate).cert.pem

$(ultimatedirectory)/public/certs/$(ultimate).cer : $(ultimatedirectory)/public/certs/$(ultimate).cert.pem
	mkdir -p $(ultimatedirectory)/public/certs
	openssl x509 \
	-inform PEM \
	-in $(ultimatedirectory)/public/certs/$(ultimate).cert.pem \
	-outform DER \
	-out $(ultimatedirectory)/public/certs/$(ultimate).cer

$(ultimatedirectory)/public/certs/$(ultimate).crt : $(ultimatedirectory)/public/certs/$(ultimate).cer
	mkdir -p $(ultimatedirectory)/public/certs
	cp $(ultimatedirectory)/public/certs/$(ultimate).cer $(ultimatedirectory)/public/certs/$(ultimate).crt

$(ultimatedirectory)/public/certs/$(ultimate).cert.der : $(ultimatedirectory)/public/certs/$(ultimate).cer
	mkdir -p $(ultimatedirectory)/public/certs
	cp $(ultimatedirectory)/public/certs/$(ultimate).cer $(ultimatedirectory)/public/certs/$(ultimate).cert.der

$(ultimatedirectory)/public/certs/$(ultimate).p7b : $(ultimatedirectory)/public/certs/$(ultimate).cert.pem
	mkdir -p $(ultimatedirectory)/public/certs
	openssl crl2pkcs7 \
	-nocrl \
	-certfile $(ultimatedirectory)/public/certs/$(ultimate).cert.pem \
	-out $(ultimatedirectory)/public/certs/$(ultimate).p7b

$(ultimatedirectory)/public/certs/$(ultimate).p7r : $(ultimatedirectory)/public/certs/$(ultimate).p7b
	mkdir -p $(ultimatedirectory)/public/certs
	cp $(ultimatedirectory)/public/certs/$(ultimate).p7b $(ultimatedirectory)/public/certs/$(ultimate).p7r

$(ultimatedirectory)/public/certs/$(ultimate).spc : $(ultimatedirectory)/public/certs/$(ultimate).p7b
	mkdir -p $(ultimatedirectory)/public/certs
	cp $(ultimatedirectory)/public/certs/$(ultimate).p7b $(ultimatedirectory)/public/certs/$(ultimate).spc

$(ultimatedirectory)/public/certs/$(ultimate).cert.pfx : $(ultimatedirectory)/public/certs/$(ultimate).cert.pem
	mkdir -p $(ultimatedirectory)/public/certs
	openssl pkcs12 \
	-export \
	-nokeys \
	-in $(ultimatedirectory)/public/certs/$(ultimate).cert.pem \
	-out $(ultimatedirectory)/public/certs/$(ultimate).cert.pfx \
	-name "Ultimate Certificate Authority $(ultimate_serial)" \
	-passout pass:

$(ultimatedirectory)/public/certs/$(ultimate).cert.p12 : $(ultimatedirectory)/public/certs/$(ultimate).cert.pfx
	mkdir -p $(ultimatedirectory)/public/certs
	cp $(ultimatedirectory)/public/certs/$(ultimate).cert.pfx $(ultimatedirectory)/public/certs/$(ultimate).cert.p12

#
# Certificate Revocation List Generation
#

ultimate_crl : $(ultimatedirectory)/public/crls/$(ultimate).crl.pem
$(ultimatedirectory)/public/crls/$(ultimate).crl.pem :
	mkdir -p $(ultimatedirectory)/private
	touch $(ultimatedirectory)/private/database.db
	mkdir -p $(ultimatedirectory)/public/crls
	openssl ca \
	-gencrl \
	-config ./configuration/ultimate.config \
	-out $(ultimatedirectory)/public/crls/$(ultimate).crl.pem

#
# Certificate + Key Pair Generation
#

$(ultimatedirectory)/private/ultimate$(ultimate_serial).pair.pfx : $(ultimatedirectory)/public/ultimate$(ultimate_serial).cert.pem $(ultimatedirectory)/private/ultimate$(ultimate_serial).key.pem
	mkdir -p $(ultimatedirectory)/public/certs
	mkdir -p $(ultimatedirectory)/private/keys
	openssl pkcs12 \
	-export \
	-in $(ultimatedirectory)/public/certs/ultimate$(ultimate_serial).cert.pem \
	-inkey $(ultimatedirectory)/private/certs/ultimate$(ultimate_serial).key.pem \
	-out $(ultimatedirectory)/private/keys/ultimate$(ultimate_serial).pair.pfx \
	-name "Ultimate Certificate Authority $(ultimate_serial)" \
	-passout pass:

#
# Package Generation
#

ultimate_package : packages/ultimate$(ultimate_serial).zip
packages/ultimate$(ultimate_serial).zip : $(ultimate_tls)
	mkdir -p ./packages
	zip -rq ./packages/ultimate$(ultimate_serial).zip $(ultimatedirectory) ./documentation/readme.txt

# crlDistributionPoints   = ULTIMATE_CRL_URI