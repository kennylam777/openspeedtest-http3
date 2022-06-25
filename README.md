# OpenspeedTest with HTTP/3

This docker image is built for testing HTTP/3 performece on Nginx + Cloudflare quiche.


## Example
Launch with `http3_cc_algorithm=reno`, mounted with custom SSL certificate files.
```
docker run --name nginx --rm -ti -e QUIC_CC=reno -p 443:443 -p 443:443/udp -v $PWD/ssl:/etc/ssl kennylam777/openspeedtest-http3
```

## Known Issues
1. Some cloud service provider may throttle UDP traffic, resulting slow performance for HTTP/3.