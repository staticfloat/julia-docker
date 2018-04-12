#!/bin/bash

# Generally useful routines for building crosscompiler stuff

## Function to take in a target such as `aarch64-linux-gnu`` and spit out a
## linux kernel arch like "arm64".
target_to_linux_arch()
{
    case "$1" in
        arm*)
            echo "arm"
            ;;
        aarch64*)
            echo "arm64"
            ;;
        powerpc*)
            echo "powerpc"
            ;;
        i686*)
            echo "x86"
            ;;
        x86*)
            echo "x86"
            ;;
    esac
}

## Function to take in a target such as `x86_64-apple-darwin14` and spit out
## an SDK version such as "10.10"
target_to_darwin_sdk()
{
    case "$1" in
        *darwin14*)
            echo "10.10"
            ;;
        *darwin15*)
            echo "10.11"
            ;;
        *darwin16*)
            echo "10.12"
            ;;
        *darwin17*)
            echo "10.13"
            ;;
    esac
}

target_to_clang_target()
{
    case "$1" in
        x86_64-apple-darwin14)
            echo "x86_64-apple-macosx10.10"
            ;;
        x86_64-apple-darwin15)
            echo "x86_64-apple-macosx10.11"
            ;;
        x86_64-apple-darwin16)
            echo "x86_64-apple-macosx10.12"
            ;;
        x86_64-apple-darwin17)
            echo "x86_64-apple-macosx10.13"
            ;;
        x86_64-unknown-freebsd*)
            echo "x86_64-unknown-freebsd11.1"
            ;;
    esac
}

get_sysroot()
{
    if [[ "${compiler_target}" == *apple* ]]; then
        sdk_version="$(target_to_darwin_sdk ${compiler_target})"
        echo "/opt/${compiler_target}/MacOSX${sdk_version}.sdk"
    else
        echo "/opt/${compiler_target}/${compiler_target}/sys-root"
    fi
}

