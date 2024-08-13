print () {
    YELLOW='\033[0;33m'
    RESET='\033[0m'
    echo "(${SECONDS}s) ${YELLOW}$1${RESET}"
}

error () {
    RED='\033[0;31m'
    RESET='\033[0m'
    echo "(${SECONDS}s) ${RED}$1${RESET}"
    exit 1
}

remoteCall () {
   command=$1
   ignore_error=$2

   ssh $HOST "$1"
   return_code=$?

   if [ -z "$ignore_error" -a "$return_code" != 0 ]; then
       error "Command \"$1\" returned error code $return_code"
   fi
}
