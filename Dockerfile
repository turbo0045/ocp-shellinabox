FROM registry.access.redhat.com/ubi7/ubi-minimal:latest

MAINTAINER Louis P. Santillan <lpsantil@gmail.com>

WORKDIR /tmp

# Run as root
USER 0

# Add our init script
ADD startsiab.sh /opt/startsiab.sh
# Add our logo
ADD siab.logo.txt /opt/siab.logo.txt
# Fix up the Reverse coloring
ADD black-on-white.css /usr/share/shellinabox/black-on-white.css
# Add nano syntax highlighting for Dockerfiles
ADD dockerfile.nanorc /usr/share/nano/dockerfile.nanorc
# Add nano syntax highlighting for JS
ADD javascript.nanorc /usr/share/nano/javascript.nanorc
# Enable nano syntax highlighting
ADD nanorc /tmp/nanorc
# Enable custom motd
ADD motd /etc/motd

# Install EPEL
# Install our developer tools (tmux, ansible, nano, vim, bash-completion, wget)
# Free up some space
# Install oc
# Add our developer user
# Bring in nano's user config
# Give nano's user config the correct ownership
# Set the default password for our 'developer' user
# Randomize root's password
# Be sure to remove login's lock file
RUN echo "" && \
    cat /opt/siab.logo.txt && \
    echo "=== Installing EPEL ===" && \
    curl -o /tmp/epel.rpm http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-13.noarch.rpm && \
    rpm -ivh /tmp/epel.rpm && \
    echo "\n=== Installing developer tools ===" && \
    microdnf \
       --enablerepo=rhel-7-server-rpms \
       --enablerepo=rhel-7-server-extras-rpms \
       --enablerepo=rhel-7-server-optional-rpms \
       --enablerepo=rhel-7-server-ose-3.11-rpms \
       --enablerepo=rhel-7-server-devtools-rpms \
       --enablerepo=rhel-server-rhscl-7-rpms \
       --enablerepo=epel \
       install \
       jq vim screen which hostname passwd tmux nano wget git \
       bash-completion openssl shellinabox util-linux expect \
       atomic-openshift-clients \
    && \
    microdnf clean all && \
    cd /tmp && \
    echo "\n=== Installing 'developer' user ===" && \
    useradd -u 1001 developer -m && \
    mkdir -pv /home/developer/bin /home/developer/tmp && \
    echo "\n=== Bringing in nano's user config ===" && \
    mv -v /tmp/nanorc /home/developer/.nanorc && \
    echo "\n=== Giving nano's user config the correct ownership ===" && \
    chown -R 1001:1001 /home/developer && \
    echo "\n=== Setting the default password for our 'developer' user ===" && \
    ( echo "developer" | passwd developer --stdin ) && \
    echo "\n=== Randomizing root's password ===" && \
    ( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 128 | head -n 1 | passwd root --stdin ) && \
    echo "\n=== Removing login's lock file ===" && \
    rm -f /var/run/nologin && \
    echo "*** Done building siab container ***" && \
    cat /opt/siab.logo.txt && \
    echo ""


# shellinabox will listen on 8080
EXPOSE 8080

# Run as developer
USER 1001

# Run our init script
CMD /opt/startsiab.sh
