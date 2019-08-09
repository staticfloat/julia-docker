#!/bin/bash

gpg -u julia --armor --detach-sig --batch --yes "$1"
