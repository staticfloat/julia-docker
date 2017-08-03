#!/bin/bash

if [[ -z "${target}" ]]; then
    # Fast path if target is empty
    /bin/uname "$@"
    exit 0
fi

# ${target} overrides the -s part of uname
s_flag()
{
    case "${target}" in
        *-linux-*)
            echo "Linux"
            ;;
        *-apple-*)
            echo "Darwin"
            ;;
        *-mingw-*)
            echo "WINNT"
            ;;
        '')
            echo $(/bin/uname -s)
            ;;
    esac
}

a_flag()
{
    echo $(s_flag) $(/bin/uname -a | cut -d' ' -f2-11) $(m_flag) $(m_flag) $(m_flag) $(s_flag)
}

m_flag()
{
    case "${target}" in
        arm*)
            echo "armv7l"
            ;;
        powerpc64le*)
            echo "ppc64le"
            ;;
        x86_64*)
            echo "x86_64"
            ;;
        aarch64*)
            echo "aarch64"
            ;;
    esac
}

if [[ -z "$@" ]]; then
    s_flag
else
    for flag in $@; do
        case "${flag}" in
            -a)
                a_flag
                ;;
            -s)
                s_flag
                ;;
            -m)
                m_flag
                ;;
            -p)
                m_flag
                ;;
            -i)
                m_flag
                ;;
            *)
                /bin/uname ${flag}
                ;;
        esac
    done
fi
