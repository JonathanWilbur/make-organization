# OrgMake

* Author: [Jonathan M. Wilbur](http://jonathan.wilbur.space) <[jonathan@wilbur.space](mailto:jonathan@wilbur.space)>
* Copyright Year: 2018
* License: [MIT License](https://mit-license.org/)
* Version: [1.0.0](http://semver.org/)

## System Requirements

* Linux or Mac OS X
* OpenSSL or LibreSSL
* GNU Make

## Configuration

Modify `configuration.make`. It's pretty self-explanatory.

## Running

Run with `make` like so:

```bash
make
```

## Results

You will have all of the cryptographic items for a root certificate authority
in `ultimate##.zip`, where `##` is `ultimate_serial` set in `configuration.make`,
and all of the cryptographic items for an intermediate certificate authority
in `penultimate##.zip`, where `##` is `penultimate_serial` set in
`configuration.make`.

## Contact Me

If you would like to suggest fixes or improvements on this tool, please just
[leave an issue on this GitHub page](https://github.com/JonathanWilbur/asn1-d/issues). If you would like to contact me for other reasons,
please email me at [jonathan@wilbur.space](mailto:jonathan@wilbur.space)
([My GPG Key](http://jonathan.wilbur.space/downloads/jonathan@wilbur.space.gpg.pub))
([My TLS Certificate](http://jonathan.wilbur.space/downloads/jonathan@wilbur.space.chain.pem)). :boar: