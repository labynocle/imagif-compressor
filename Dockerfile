FROM debian:buster-slim

RUN	apt-get update && \
	apt-get install -y \
		pngcrush \
		gifsicle \
		imagemagick \
		libjpeg-progs

ADD ./scripts/imagif-compressor.sh /root/imagif-compressor.sh

VOLUME /data-volume
WORKDIR /data-volume
ENTRYPOINT ["bash", "/root/imagif-compressor.sh", "/data-volume"]
