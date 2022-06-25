ARG ALPINE_VERSION="3.16.0"
FROM alpine:$ALPINE_VERSION as builder

WORKDIR /src

RUN --mount=type=cache,target=/var/cache/apk/ \
    apk add \
        bash \
        build-base \
        cargo \
        curl \
        cmake \
        coreutils \
        g++ \
        git \
        make \
        openssl \
        patch \
        pcre-dev \
        zlib-dev

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    git clone --recursive -b "nginx.set_cc_algorithm.bbr2" https://github.com/kennylam777/quiche.git && \
    cd quiche && \
    cargo build

RUN curl -O https://nginx.org/download/nginx-1.16.1.tar.gz && \
    tar xzvf nginx-1.16.1.tar.gz

RUN cd nginx-1.16.1 && \ 
    patch -p01 < ../quiche/nginx/nginx-1.16.patch && \
    ./configure \
       --prefix=/usr/local \
       --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module \
       --with-http_v2_module \
       --with-http_v3_module \
       --with-openssl=../quiche/quiche/deps/boringssl \
       --with-quiche=../quiche && \
    make -j && \
    make install

RUN git clone https://github.com/openspeedtest/Speed-Test.git && \
    cd Speed-Test && \
    rm downloading
RUN openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -subj "/C=GB/O=Kenny's playground/CN=openspeedtest-http3" -keyout /etc/ssl/nginx.key -out /etc/ssl/nginx.crt

FROM alpine:$ALPINE_VERSION as runner

RUN apk add --no-cache \
        libgcc \
        libunwind \
        pcre
        

COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /src/Speed-Test/ /usr/share/nginx/html/
COPY --from=builder /etc/ssl/ /etc/ssl/

COPY nginx.conf /usr/local/conf/nginx.conf
COPY OpenSpeedTest-Server-HTTP3.conf /etc/nginx/conf.d/

RUN mkdir -p /usr/local/nginx/logs/ && \
    ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/nginx/logs/error.log

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

EXPOSE 80 443 443/UDP

ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV QUIC_PORT 443
ENV QUIC_CC reno

CMD ["/usr/local/bin/entrypoint.sh"]
