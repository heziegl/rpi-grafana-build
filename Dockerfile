#FROM resin/rpi-raspbian:jessie
FROM resin/artik710-golang:1.9.4

# install dependencies
RUN	apt-get update \
	&& apt-get install --no-install-recommends -qy wget curl git libfreetype6 libfontconfig1 python build-essential ruby ruby-dev rpm libicu52

WORKDIR	~


# install phantomjs 2.1.1
RUN    wget https://github.com/timstanley1985/phantomjs-linux-armv6l/raw/master/phantomjs-2.1.1-linux-armv6l.tar.gz && \
       tar -xf phantomjs-2.1.1-linux-armv6l.tar.gz && \
       cp phantomjs-2.1.1-linux-armv6l/bin/phantomjs /usr/local/bin/phantomjs && \
       chmod a+x /usr/local/bin/phantomjs && \
       rm phantomjs-2.1.1-linux-armv6l.tar.gz && \
       rm -r phantomjs-2.1.1-linux-armv6l/



ENV    NODE_VER 8.10.0
RUN    wget https://nodejs.org/dist/v$NODE_VER/node-v$NODE_VER-linux-armv7l.tar.gz && \
       tar -xf node-v$NODE_VER-linux-armv7l.tar.gz && \
       cd node-v$NODE_VER-linux-armv7l && \
       cp -R * /usr/local/ && \
       cd .. && \
       rm -r node-v$NODE_VER-linux-armv7l && \
       rm  node-v$NODE_VER-linux-armv7l.tar.gz



ARG     GRAFANA_VERSION
# invalidate docker cache
RUN	echo building $GRAFANA_VERSION

# FIXME: exit 0 hack for error "no buildable Go source files in /gopath1.5/src/github.com/grafana/grafana"
WORKDIR $GOPATH
RUN	go get -t -d github.com/grafana/grafana; exit 0

# set working dir
WORKDIR $GOPATH/src/github.com/grafana/grafana

# if GRAFANA_VERSION not master, get specific version
#RUN	if [[ $GRAFANA_VERSION != master* ]]; then git checkout tags/v$GRAFANA_VERSION; fi
RUN	git checkout tags/v$GRAFANA_VERSION

# go setup
#RUN	go run build.go setup
#RUN	npm install -g yarn
#RUN	yarn install --pure-lockfile
#RUN	npm run build



# install fpm (for *.deb + *.rpm creation)
RUN     gem install fpm

# go setup
RUN     go run build.go setup
RUN     go run build.go build

# build + package
RUN     go run build.go package




VOLUME	/dist

CMD	if [ -d /dist ]; then cp $GOPATH/src/github.com/grafana/grafana/dist/* /dist; fi
