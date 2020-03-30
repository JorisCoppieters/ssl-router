# After certbot is installed

rm -f /etc/nginx/conf.d/default.conf

rm -f /etc/nginx/conf.d/variables.conf
touch /etc/nginx/conf.d/variables.conf

echo "Email: $EMAIL"
echo "map \$host \$EMAIL { default $EMAIL; }" >> /etc/nginx/conf.d/variables.conf

echo "Domain: $DOMAIN"
echo "map \$host \$DOMAIN { default $DOMAIN; }" >> /etc/nginx/conf.d/variables.conf

if [[ ! $HTTP_PORT ]]; then
    HTTP_PORT=80
fi
echo "HTTP Port: $HTTP_PORT"
echo "map \$host \$HTTP_PORT { default $HTTP_PORT; }" >> /etc/nginx/conf.d/variables.conf

if [[ ! $HTTPS_PORT ]]; then
    HTTPS_PORT=443
fi
echo "HTTPS Port: $HTTPS_PORT"
echo "map \$host \$HTTPS_PORT { default $HTTPS_PORT; }" >> /etc/nginx/conf.d/variables.conf

echo "Internal Domain: $INTERNAL_DOMAIN"
echo "map \$host \$internal_domain { default $INTERNAL_DOMAIN; }" >> /etc/nginx/conf.d/variables.conf

echo "Internal Port: $INTERNAL_PORT"
echo "map \$host \$internal_port { default $INTERNAL_PORT; }" >> /etc/nginx/conf.d/variables.conf

mkdir -p /cert

if [[ $CERT_GENERATOR == "certbot" ]]; then
    if [[ ! -f /cert/server.crt ]]; then
        /usr/local/bin/certbot-auto certonly \
            -n \
            --non-interactive \
            --agree-tos \
            --nginx \
            -m $EMAIL \
            -d $DOMAIN
        cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /cert/server.crt
        cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /cert/server.key
    fi

elif [[ $CERT_GENERATOR == "self-signed" ]]; then
    openssl req \
        -new \
        -newkey rsa:2048 \
        -days 365 \
        -nodes \
        -x509 \
        -subj "/C=NZ/ST=_/L=_/O=_/CN=$DOMAIN" \
        -keyout /cert/server.key \
        -out /cert/server.crt

elif [[ $CERT_GENERATOR == "injected" ]]; then
    echo -n $CERT_ENCODED > "/cert/server.enc"
    echo -n $CERT_PWD > "/cert/server.pwd"
    cat "/cert/server.enc" | base64 -d > "/cert/server.pfx"
    openssl pkcs12 -passin file:"/cert/server.pwd" -in "/cert/server.pfx" -out "/cert/server.key" -nodes -nocerts
    openssl pkcs12 -passin file:"/cert/server.pwd" -in "/cert/server.pfx" -out "/cert/server.crt" -nodes -nokeys

fi

cp /etc/nginx/conf.d.ssl/server.conf /etc/nginx/conf.d/server.conf
nginx -s reload
