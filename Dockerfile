FROM hypriot/rpi-golang

# install dependencies
RUN	apt-get update \
	&& apt-get install --no-install-recommends -qy wget curl libfreetype6 libfontconfig1 python build-essential ruby ruby-dev rubygems rpm

# insatll phantomjs
RUN	cd /usr/local/bin \
	&& wget https://github.com/piksel/phantomjs-raspberrypi/raw/master/bin/phantomjs \
	&& chmod a+x phantomjs

# install node
RUN	curl -sLS https://apt.adafruit.com/add |bash \
	&& apt-get install -qy node

# install fpm
RUN     gem install fpm



# FIXME: exit 0 hack for error "no buildable Go source files in /gopath1.5/src/github.com/grafana/grafana"
WORKDIR $GOPATH
RUN 	go get -t -d github.com/grafana/grafana; exit 0

# set working dir
WORKDIR $GOPATH/src/github.com/grafana/grafana

# get specific version
ARG	GRAFANA_VERSION
RUN	git checkout tags/v$GRAFANA_VERSION

# go setup
RUN     go run build.go setup \
        && godep restore

RUN	npm install -g grunt-cli

RUN	npm install

RUN	go run build.go build

RUN     go run build.go package


VOLUME	/dist

CMD	if [ -d /dist ]; then cp $GOPATH/src/github.com/grafana/grafana/dist/* /dist; fi
