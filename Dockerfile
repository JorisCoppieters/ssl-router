FROM nginx:latest

WORKDIR /root

# Add command to bash history, to hit [Up] + [Enter] to run it quickly
RUN \
    echo "/root/install-certs.sh" >> ".bash_history"

# Setting bash greeting http://patorjk.com/software/taag/#p=display&f=Ogre&t=env%20-%20python
RUN touch ".bashrc"
RUN \
    echo "" >> ".bashrc" && \
    echo "echo -en \"\e[0;35m\"" >> ".bashrc" && \
    echo "echo \"         _                       _            \"" >> ".bashrc" && \
    echo "echo \" ___ ___| |      _ __ ___  _   _| |_ ___ _ __ \"" >> ".bashrc" && \
    echo "echo \"/ __/ __| |_____| '__/ _ \| | | | __/ _ \ '__|\"" >> ".bashrc" && \
    echo "echo \"\__ \__ \ |_____| | | (_) | |_| | ||  __/ |   \"" >> ".bashrc" && \
    echo "echo \"|___/___/_|     |_|  \___/ \__,_|\__\___|_|   \"" >> ".bashrc" && \
    echo "echo" >> ".bashrc" && \
    echo "echo" >> ".bashrc" && \
    echo "echo -en \"\e[0;32m\"" >> ".bashrc" && \
    echo "echo -n \"Run \"" >> ".bashrc" && \
    echo "echo -en \"\e[0;36m\"" >> ".bashrc" && \
    echo "echo -n \"/root/install-certs.sh\"" >> ".bashrc" && \
    echo "echo -en \"\e[0;32m\"" >> ".bashrc" && \
    echo "echo -n \" to get started (hit the up key)\"" >> ".bashrc" && \
    echo "echo \n" >> ".bashrc" && \
    echo "echo -e \"\e[0m\"" >> ".bashrc"

RUN apt update -y && apt install -y \
    wget \
    procps \
    iputils-ping \
    nano \
    curl

RUN wget https://dl.eff.org/certbot-auto
RUN mv certbot-auto /usr/local/bin/certbot-auto
RUN chown root /usr/local/bin/certbot-auto
RUN chmod 0755 /usr/local/bin/certbot-auto
RUN /usr/local/bin/certbot-auto --install-only --non-interactive

RUN mkdir -p /etc/nginx/conf.d
COPY conf.d /etc/nginx/conf.d/
COPY conf.d.ssl /etc/nginx/conf.d.ssl/
COPY letsencrypt /etc/letsencrypt.ssl
COPY install-certs.sh /root/install-certs.sh
