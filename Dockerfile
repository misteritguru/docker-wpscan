FROM debian:latest
MAINTAINER WPScan Team <wpscanteam@gmail.com>

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Disable the installation of Recommended and Suggested packages
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf
RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf

RUN apt-get update
RUN apt-get -y install libcurl4-gnutls-dev libxml2 libxml2-dev libxslt1-dev ruby-dev git curl make ca-certificates procps

# RVM Install
RUN \curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN \curl -sSL https://get.rvm.io | bash -s stable --ruby
RUN /bin/bash -l -c "source /usr/local/rvm/scripts/rvm"
RUN echo 'source /usr/local/rvm/scripts/rvm' >> ~/.bashrc

# Recommended Ruby Version for WPScan
RUN /bin/bash -l -c "rvm install 2.1.3"
RUN /bin/bash -l -c "rvm use 2.1.3 --default"

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN /bin/bash -l -c "gem install bundler"

RUN git clone https://github.com/wpscanteam/wpscan.git
# Deleting the gemset to be able to call wpscan.rb from outside the wpscan directory
RUN rm /wpscan/.ruby-gemset
WORKDIR /wpscan
RUN /bin/bash -l -c "bundle install --without test"

RUN echo '#!/bin/bash' > /bin/wpscan
RUN echo 'source /usr/local/rvm/scripts/rvm' >> /bin/wpscan # Needed to be able run the wpscan command directly with 'docker run'
RUN echo 'cd /wpscan/ && ./wpscan.rb "$@"' >> /bin/wpscan
RUN chmod 755 /bin/wpscan
RUN wpscan --update
