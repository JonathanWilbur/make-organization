This package contains your keys and certificates that serve as the basis of
your identity and the means by which you encrypt communications between you
and others.

In this package, you will find two folders, public and private. The contents of
public may be shared freely to anybody, though it is typically wise to only
give the conents of it to people who need it. Anything in the private folder
must be kept secret. Do not EVER give anything in this folder to anybody.

When somebody requests your certificate, most of the time, you will want to
give them ./public/certs/<yourname>.chain.pem.