FROM alpine:3.11.2 AS build_stage

WORKDIR /
RUN apk --update add python py-pip build-base automake libtool m4 autoconf libevent-dev openssl-dev c-ares-dev
RUN pip install docutils \
  && wget https://www.pgbouncer.org/downloads/files/1.14.0/pgbouncer-1.14.0.tar.gz \
  && tar zxf pgbouncer-1.14.0.tar.gz && rm pgbouncer-1.14.0.tar.gz \
  && cd /pgbouncer-1.14.0/ \
  && ./configure --prefix=/pgbouncer \
  && make \
  && make install

WORKDIR /bin
RUN ln -s ../usr/bin/rst2man.py rst2man

FROM alpine:3.11.2
RUN apk --update add libevent openssl c-ares

WORKDIR /
RUN wget https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt \
 && openssl x509 -inform DER -in BaltimoreCyberTrustRoot.crt -text -out /etc/root.crt 

WORKDIR /
COPY --from=build_stage /pgbouncer /pgbouncer

ADD entrypoint.sh ./
ENTRYPOINT ["./entrypoint.sh"]
