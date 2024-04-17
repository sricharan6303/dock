#!/bin/sh
set -x
# Check if curl, tar, and mv are installed
if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1 ; then
    echo "curl and tar are required but not installed. Exiting with status 1." >&2
    exit 1
fi

# Call jdk-download-url-for-alpine.sh with JAVA_VERSION as an argument
# The two scripts should be in the same directory.
# That's why we're trying to find the directory of the current script and use it to call the other script.
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit; pwd)
if ! DOWNLOAD_URL=$("${SCRIPT_DIR}"/jdk-download-url-for-alpine.sh "${JAVA_VERSION}"); then
    echo "Error: Failed to fetch the URL. Exiting with status 1." >&2
    exit 1
fi

# Use curl to download the JDK archive from the URL
if ! curl --silent --location --output /tmp/jdk.tar.gz "${DOWNLOAD_URL}"; then
    echo "Error: Failed to download the JDK archive. Exiting with status 1." >&2
    exit 1
fi

# Extract the archive to the /opt/ directory
if ! tar -xzf /tmp/jdk.tar.gz -C /opt/; then
    echo "Error: Failed to extract the JDK archive. Exiting with status 1." >&2
    exit 1
fi

# Get the name of the extracted directory
EXTRACTED_DIR=$(tar -tf /tmp/jdk.tar.gz | head -1 | cut -f1 -d"/")

# Rename the extracted directory to /opt/jdk-${JAVA_VERSION}
if ! mv "/opt/${EXTRACTED_DIR}" "/opt/jdk-${JAVA_VERSION}"; then
    echo "Error: Failed to rename the extracted directory. Exiting with status 1." >&2
    exit 1
fi

# Remove the downloaded archive
if ! rm -f /tmp/jdk.tar.gz; then
    echo "Error: Failed to remove the downloaded archive. Exiting with status 1." >&2
    exit 1
fi
