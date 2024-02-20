# a function to install apt packages only if they are not installed
# source : https://github.com/rocker-org/rocker-versioned2/blob/master/scripts
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}
