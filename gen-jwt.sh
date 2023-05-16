#!/bin/sh
LC_ALL=C tr -dc '[:alnum:]' < /dev/random | head -c512 | sha256sum | awk '{ print $1 }' | tr -d '\n' > ./shared/jwt.secret
