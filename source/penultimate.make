penultimate = penultimate$(penultimate_serial)
penultimatedirectory = output/$(penultimate)

penultimate_infrastructure_directories = \
	$(penultimatedirectory)/private/keys \
	$(penultimatedirectory)/public/certs \
	$(penultimatedirectory)/public/crls

penultimate_infrastructure_files = \
	$(penultimatedirectory)/private/database.db \
	$(penultimatedirectory)/private/serial \
	$(penultimatedirectory)/private/crlnumber \
	$(penultimatedirectory)/private/.rand

penultimate_tls_keys = \
	$(penultimatedirectory)/private/keys/$(penultimate).key.pem \
	$(penultimatedirectory)/private/keys/$(penultimate).key \
	$(penultimatedirectory)/private/keys/$(penultimate).key.der \
	$(penultimatedirectory)/private/keys/$(penultimate).key.pfx

penultimate_tls_certs = \
	$(penultimatedirectory)/public/certs/$(penultimate).cert.pem \
	$(penultimatedirectory)/public/certs/$(penultimate).chain.pem \
	$(penultimatedirectory)/public/certs/$(penultimate).cer \
	$(penultimatedirectory)/public/certs/$(penultimate).crt \
	$(penultimatedirectory)/public/certs/$(penultimate).cert.der \
	$(penultimatedirectory)/public/certs/$(penultimate).p7b \
	$(penultimatedirectory)/public/certs/$(penultimate).p7r \
	$(penultimatedirectory)/public/certs/$(penultimate).spc \
	$(penultimatedirectory)/public/certs/$(penultimate).cert.pfx

penultimate_tls = $(penultimate_tls_keys) $(penultimate_tls_certs)

#
# Infrastructure Generation
#

./configuration/penultimate.config : ./configuration/penultimate.config.template
	sed \
	-e 's/PENULTIMATE_SERIAL/$(penultimate_serial)/g' \
	-e 's/ORGANIZATION_NAME/$(organization_name)/g' \
	< ./configuration/penultimate.config.template \
	> ./configuration/penultimate.config

#
# TLS Key Generation
#

penultimate_tls_key : $(penultimate_tls_keys)

$(penultimatedirectory)/private/keys/$(penultimate).key.pem :
	mkdir -p $(penultimatedirectory)/private/keys
	openssl genrsa \
	-out $(penultimatedirectory)/private/keys/$(penultimate).key.pem 4096

$(penultimatedirectory)/private/keys/$(penultimate).key : $(penultimatedirectory)/private/keys/$(penultimate).key.pem
	mkdir -p $(penultimatedirectory)/private/keys
	cp \
	$(penultimatedirectory)/private/keys/$(penultimate).key.pem \
	$(penultimatedirectory)/private/keys/$(penultimate).key

$(penultimatedirectory)/private/keys/$(penultimate).key.der : $(penultimatedirectory)/private/keys/$(penultimate).key
	mkdir -p $(penultimatedirectory)/private/keys
	openssl rsa \
	-in $(penultimatedirectory)/private/keys/$(penultimate).key \
	-outform DER \
	-out $(penultimatedirectory)/private/keys/$(penultimate).key.der

$(penultimatedirectory)/private/keys/$(penultimate).key.pfx : $(penultimatedirectory)/private/keys/$(penultimate).key
	mkdir -p $(penultimatedirectory)/private/keys
	openssl pkcs12 \
	-export \
	-nocerts \
	-inkey $(penultimatedirectory)/private/keys/$(penultimate).key \
	-out $(penultimatedirectory)/private/keys/$(penultimate).key.pfx \
	-passout pass:

#
# TLS Certificate Generation
#

penultimate_tls_cert : $(penultimate_tls_certs)

$(penultimatedirectory)/public/certs/$(penultimate).cert.pem : $(penultimatedirectory)/private/keys/$(penultimate).key ./configuration/penultimate.config
	mkdir -p ./output/certs
	mkdir -p $(penultimatedirectory)/private/keys
	mkdir -p $(penultimatedirectory)/public/certs
	mkdir -p $(penultimatedirectory)/public/csrs
	touch $(penultimatedirectory)/private/.rand
	touch $(ultimatedirectory)/private/database.db
	dd if=/dev/urandom of=$(penultimatedirectory)/private/.rand bs=256 count=1
	echo 01 > $(penultimatedirectory)/private/serial
	echo 01 > $(penultimatedirectory)/private/crlnumber
	openssl req \
	-new \
	-config ./configuration/penultimate.config \
	-key $(penultimatedirectory)/private/keys/penultimate$(penultimate_serial).key \
	-out $(penultimatedirectory)/public/csrs/penultimate$(penultimate_serial).csr.pem
	openssl ca \
	-batch \
	-days 1800 \
	-notext \
	-config ./configuration/ultimate.config \
	-extensions penultimate \
	-in $(penultimatedirectory)/public/csrs/penultimate$(penultimate_serial).csr.pem \
	-out $(penultimatedirectory)/public/certs/penultimate$(penultimate_serial).cert.pem
	cat $(penultimatedirectory)/public/certs/penultimate$(penultimate_serial).cert.pem

$(penultimatedirectory)/public/certs/$(penultimate).chain.pem : $(penultimatedirectory)/public/certs/$(penultimate).cert.pem $(ultimatedirectory)/public/certs/$(ultimate).cert.pem
	mkdir -p $(penultimatedirectory)/public/certs
	cat \
	$(penultimatedirectory)/public/certs/penultimate$(penultimate_serial).cert.pem \
	$(ultimatedirectory)/public/certs/ultimate$(ultimate_serial).cert.pem \
	> $(penultimatedirectory)/public/certs/penultimate$(penultimate_serial).chain.pem

$(penultimatedirectory)/public/certs/$(penultimate).cer : $(penultimatedirectory)/public/certs/$(penultimate).cert.pem
	mkdir -p $(penultimatedirectory)/public/certs
	openssl x509 \
	-inform PEM \
	-in $(penultimatedirectory)/public/certs/$(penultimate).cert.pem \
	-outform DER \
	-out $(penultimatedirectory)/public/certs/$(penultimate).cer

$(penultimatedirectory)/public/certs/$(penultimate).crt : $(penultimatedirectory)/public/certs/$(penultimate).cer
	mkdir -p $(penultimatedirectory)/public/certs
	cp $(penultimatedirectory)/public/certs/$(penultimate).cer $(penultimatedirectory)/public/certs/$(penultimate).crt

$(penultimatedirectory)/public/certs/$(penultimate).cert.der : $(penultimatedirectory)/public/certs/$(penultimate).cer
	mkdir -p $(penultimatedirectory)/public/certs
	cp $(penultimatedirectory)/public/certs/$(penultimate).cer $(penultimatedirectory)/public/certs/$(penultimate).cert.der

$(penultimatedirectory)/public/certs/$(penultimate).p7b : $(penultimatedirectory)/public/certs/$(penultimate).cert.pem
	mkdir -p $(penultimatedirectory)/public/certs
	openssl crl2pkcs7 \
	-nocrl \
	-certfile $(penultimatedirectory)/public/certs/$(penultimate).cert.pem \
	-out $(penultimatedirectory)/public/certs/$(penultimate).p7b

$(penultimatedirectory)/public/certs/$(penultimate).p7r : $(penultimatedirectory)/public/certs/$(penultimate).p7b
	mkdir -p $(penultimatedirectory)/public/certs
	cp $(penultimatedirectory)/public/certs/$(penultimate).p7b $(penultimatedirectory)/public/certs/$(penultimate).p7r

$(penultimatedirectory)/public/certs/$(penultimate).spc : $(penultimatedirectory)/public/certs/$(penultimate).p7b
	mkdir -p $(penultimatedirectory)/public/certs
	cp $(penultimatedirectory)/public/certs/$(penultimate).p7b $(penultimatedirectory)/public/certs/$(penultimate).spc

$(penultimatedirectory)/public/certs/$(penultimate).cert.pfx : $(penultimatedirectory)/public/certs/$(penultimate).cert.pem
	mkdir -p $(penultimatedirectory)/public/certs
	openssl pkcs12 \
	-export \
	-nokeys \
	-in $(penultimatedirectory)/public/certs/$(penultimate).chain.pem \
	-out $(penultimatedirectory)/public/certs/$(penultimate).cert.pfx \
	-name "Penultimate Certificate Authority $(penultimate_serial)" \
	-passout pass:

$(penultimatedirectory)/public/certs/$(penultimate).cert.p12 : $(penultimatedirectory)/public/certs/$(penultimate).cert.pfx
	mkdir -p $(penultimatedirectory)/public/certs
	cp $(penultimatedirectory)/public/certs/$(penultimate).cert.pfx $(penultimatedirectory)/public/certs/$(penultimate).cert.p12

#
# Certificate Revocation List Generation
#

penultimate_crl : $(penultimatedirectory)/public/crls/$(penultimate).crl.pem
$(penultimatedirectory)/public/crls/$(penultimate).crl.pem :
	mkdir -p $(penultimatedirectory)/private
	touch $(penultimatedirectory)/private/database.db
	mkdir -p $(penultimatedirectory)/public/crls
	openssl ca \
	-gencrl \
	-config ./configuration/penultimate.config \
	-out $(penultimatedirectory)/public/crls/$(penultimate).crl.pem

#
# Certificate + Key Pair Generation
#

$(penultimatedirectory)/private/penultimate$(penultimate_serial).pair.pfx : $(penultimatedirectory)/public/penultimate$(penultimate_serial).cert.pem $(penultimatedirectory)/private/penultimate$(penultimate_serial).key.pem
	mkdir -p $(penultimatedirectory)/public/certs
	mkdir -p $(penultimatedirectory)/private/keys
	openssl pkcs12 \
	-export \
	-in $(penultimatedirectory)/public/certs/penultimate$(penultimate_serial).cert.pem \
	-inkey $(penultimatedirectory)/private/certs/penultimate$(penultimate_serial).key.pem \
	-out $(penultimatedirectory)/private/keys/penultimate$(penultimate_serial).pair.pfx \
	-name "Penultimate Certificate Authority $(penultimate_serial)" \
	-passout pass:

#
# Package Generation
#

penultimate_package : packages/penultimate$(penultimate_serial).zip
packages/penultimate$(penultimate_serial).zip : $(penultimate_tls)
	mkdir -p ./packages
	zip -rq ./packages/penultimate$(penultimate_serial).zip $(penultimatedirectory) ./documentation/readme.txt

# crlDistributionPoints   = penultimate_CRL_URI