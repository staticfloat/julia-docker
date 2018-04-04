USER root

# We need to override ld.so.conf to search /usr/local before /usr
RUN echo "/usr/local/lib64" > /etc/ld.so.conf.new; \
    echo "/usr/local/lib" >> /etc/ld.so.conf.new; \
    cat /etc/ld.so.conf >> /etc/ld.so.conf.new; \
    mv /etc/ld.so.conf.new /etc/ld.so.conf; \
    ldconfig

# Cleanup downloads and build.sh
RUN rm -rf /downloads /build.sh

# Remove bootstrapping compiler toolchain if we need to
RUN if [[ -n "${TEMPORARY_DEPS}" ]]; then \
        if [[ -n "$(which yum 2>/dev/null)" ]]; then \
            yum remove -y ${TEMPORARY_DEPS}; \
            yum clean all; \
        elif [[ -n "$(which apt-get 2>/dev/null)" ]]; then \
            apt-get remove -y ${TEMPORARY_DEPS}; \
            apt-get autoremove -y; \
            apt-get clean -y; \
        fi; \
    fi

# Clean up /tmp, some things leave droppings in there.
RUN rm -rf /tmp/*

# Set a default working directory that we know is good
WORKDIR /

# Use /entrypoint.sh to conditionally apply ${L32} since we cna't use ARG
# values within an actual ENTRYPOINT command.  :(
RUN echo "#!/bin/bash" > /entrypoint.sh; \
    echo "${L32} \"\$@\"" >> /entrypoint.sh; \
    chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
USER buildworker
