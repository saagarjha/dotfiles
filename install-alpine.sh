#!/bin/sh

. ./shared.sh

ask "Install bash?" && { apk add bash; ask "Change shell (bash is at $(which bash))?" && nano /etc/passwd; }
ask "Install bash-completion?" && apk add bash-completion
ask "Install nano?" && apk add nano nano-syntax
ask "Install gcc?" && apk add gcc libc-dev
ask "Install g++?" && apk add g++
ask "Install make?" && apk add make
ask "Install cmake?" && apk add cmake
true
