# First, install things we need in order to download and verify Julia
RUN ${L32} apt update && \
    ${L32} apt install -y --no-install-recommends ca-certificates curl gnupg

RUN ${L32} gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 3673DF529D9049477F76B37566E3C7DC03D6E495

# We template this in here instead of passing it in as an ARG at the top like
# we do with L32 so that we can re-use the `apt update` and `gpg --keyserver`
# steps above as much as possible as they take a nontrivial amount of time.
ARG JULIA_URL="{{JULIA_URL}}"

# Download Julia
RUN ${L32} curl -sSL "${JULIA_URL}" -o julia.tar.gz

# Verify the Julia download (this is removed for builds without a .tar.gz.asc)
RUN ${L32} curl -sSL "${JULIA_URL}.asc" -o julia.tar.gz.asc && \
    ${L32} gpg --batch --verify julia.tar.gz.asc julia.tar.gz && \
    ${L32} rm -r "${HOME}/.gnupg" julia.tar.gz.asc

# Unpack Julia into /usr
RUN ${L32} tar -xzf julia.tar.gz -C /usr --strip-components 1

# Cleanup after yourself
RUN ${L32} rm -rf /var/lib/apt/lists/* julia.tar.gz*

# Create entrypoint.sh to shoe-horn ${L32} into everything
RUN ${L32} echo "#!/bin/bash" > /entrypoint.sh && \
    ${L32} echo "${L32} \"\$@\"" >> /entrypoint.sh && \
    ${L32} chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/julia"]
