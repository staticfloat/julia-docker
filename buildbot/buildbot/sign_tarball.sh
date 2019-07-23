#!/bin/bash

gpg -u julia --armor --detach-sig --batch --passphrase-file=/root/julia.gpg.passphrase "$1"
