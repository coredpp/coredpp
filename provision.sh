HOST="root@coredpp.eu"
HOSTNAME=coredpp

# *** UTILITIES ***

source utils.sh

try_ssh () {
    local max_time=180
    local interval=1000
    local end_time=$((SECONDS + max_time))

    sleep 1

    while [ $SECONDS -lt $end_time ]; do
        ssh -q "$HOST" exit
        if [ $? -eq 0 ]; then
            print "Server is up"
            return 0
        fi
        sleep $((interval / 1000)).$((interval % 1000))
    done
    error "Could not login to server"
}

# *** MAIN SEQUENCE ***

try_ssh

print "Update & upgrade"
remoteCall "apt-get update"
remoteCall "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --with-new-pkgs"

print "Set UTC as timezone"
remoteCall "timedatectl set-timezone UTC"

print "Install fail2ban"
remoteCall "apt-get install -y fail2ban"

print "Allow up to 1024 simultaneous connection requests"
remoteCall 'grep -qxF "net.core.somaxconn=1024" /etc/sysctl.conf || echo "net.core.somaxconn=1024" >> /etc/sysctl.conf'

print "Set up hostname to $HOSTNAME"
remoteCall "echo $HOSTNAME > /etc/hostname"

print "Install utilities"
remoteCall "apt-get install -y htop sysstat neovim curl wget unzip"

print "Configure neovim"
remoteCall "mkdir /root/.config" ignoreError
remoteCall "mkdir /root/.config/nvim" ignoreError
remoteCall "wget https://raw.githubusercontent.com/fpereiro/vimrc/master/vimrc -O /root/.config/nvim/init.vim"

print "Install git"
remoteCall "apt-get install -y build-essential git"

print "Installing nginx & certbot"
remoteCall "apt-get install -y nginx"
remoteCall "apt-get install -y certbot python3-certbot-nginx"

print "Cloning the repo"
remoteCall "rm -r /var/www/coredpp /root/coredpp" ignoreError
remoteCall "git clone https://github.com/coredpp/coredpp"
remoteCall "mv /root/coredpp /var/www"


print "Setting up nginx config"
NGINX_CONF=$(cat << 'EOF'
server {
    listen 80;
    server_name coredpp.eu;

    location / {
        root /var/www/coredpp;
        index home.html;
    }

    location /readme.md {
        root /var/www/coredpp;
        index readme.md;
    }
}

server {
    listen 80;
    server_name coredpp.org;

    location / {
        root /var/www/coredpp;
        index home.html;
    }

    location /readme.md {
        root /var/www/coredpp;
        index readme.md;
    }
}
EOF
)
remoteCall "echo \"$NGINX_CONF\" > /etc/nginx/sites-enabled/default"
remoteCall "service nginx restart"

if [ "$1" == "https" ]; then
    print "Setting up HTTPS"
    # This step requires two manual interactions: 1) enter email address, 2) agree to the terms (Y)
    remoteCall "certbot --nginx -d coredpp.eu"
    remoteCall "certbot --nginx -d coredpp.org"
fi

print "Cleanup"
remoteCall "apt-get autoremove -y"
remoteCall "apt-get clean"

print "Restarting server..."
remoteCall "shutdown -r now"

try_ssh

print "Done"
exit 0
