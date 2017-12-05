#!/bin/sh

# Forcibly insert --no-same-owner into every tar invocation
/usr/bin/tar $* --no-same-owner
