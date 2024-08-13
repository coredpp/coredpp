HOST="root@coredpp.eu"

# *** UTILITIES ***

source utils.sh

# *** MAIN SEQUENCE ***

copy () {
    src=$1
    dest=$2
    rsync -avz --exclude 'node_modules' $1 $HOST:$2
    remoteCall "chown -R root $2"
    remoteCall "chgrp -R root $2"
}

print "Update repo"
copy .. /var/www/coredpp

print "Done"
exit 0
