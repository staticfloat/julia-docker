# Download OSX SDK
WORKDIR /opt/${compiler_target}
RUN source /build.sh; \
    sdk_version="$(target_to_darwin_sdk ${compiler_target})"; \
    sdk_url="https://davinci.cs.washington.edu/MacOSX${sdk_version}.sdk.tar.xz"; \
    download_unpack.sh "${sdk_url}"

# Fix weird permissions on the SDK folder
RUN chmod 755 .
RUN chmod 755 MacOSX*.sdk
