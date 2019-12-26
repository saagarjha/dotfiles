#!/bin/sh

. ./shared.sh

cat /dev/null > /etc/motd

ask "Install bash?" && { apk add bash; echo "Make sure to change your shell (bash is at $(which bash))."; }
ask "Install bash-completion?" && apk add bash-completion
ask "Install nano?" && apk add nano nano-syntax
ask "Install less?" && apk add less
ask "Install man?" && apk add man
ask "Install build-base?" && apk add build-base
ask "Install cmake?" && apk add cmake
ask "Install clang?" && apk add clang
ask "Install ag?" && apk add the_silver_searcher
true
