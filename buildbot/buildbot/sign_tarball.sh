#!/bin/bash

gpg -u julia --armor --detach-sig --batch "$1"
