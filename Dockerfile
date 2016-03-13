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


# FIXME: hack for error "no buildable Go source files in /gopath1.5/src/github.com/grafana/grafana"
RUN 	cd /gopath1.5 \
	&& go get -t -d github.com/grafana/grafana; exit 0

# get specific version
ARG	GRAFANA_TAG
RUN	cd /gopath1.5/src/github.com/grafana/grafana \
	&& git checkout tags/$GRAFANA_TAG

# go setup
RUN     cd /gopath1.5/src/github.com/grafana/grafana \
        && go run build.go setup \
        && godep restore

RUN	cd /gopath1.5/src/github.com/grafana/grafana \
	&& npm install -g grunt-cli

RUN	cd /gopath1.5/src/github.com/grafana/grafana \
	&& npm install

RUN	cd /gopath1.5/src/github.com/grafana/grafana \
	&& go run build.go build

RUN     cd /gopath1.5/src/github.com/grafana/grafana \
        && go run build.go package

VOLUME	/dist2

CMD	if [ -d /dist2 ]; then cp /gopath1.5/src/github.com/grafana/grafana/dist/* /dist2; fi
