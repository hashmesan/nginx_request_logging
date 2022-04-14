## NGINX Config for detail request body logging

This is a detail request body logging which is useful for getting RPC request body.

### Add new Logging format

Add this to http block
```

log_format detail '[$time_local] "$http_user_agent" $remote_addr - $proxy_protocol_addr '
                    '"$http_x_forwarded_for" '
                    '$status $body_bytes_sent '
                    "$http_request_id $request $request_body $http_cookie $http_sec_fetch_mode";
```

Metamask tracks $http_cookie $http_sec_fetch_mode so it might be useful to identify if it's same person but different ip.

### Setup server logging

Add this to the target server configuration
```
        access_log  /var/log/nginx/test.detail.log detail;
```

#### Test

I've setup a docker to test these configurations.

```
sh start_docker.sh
```

```
curl --location --request POST 'localhost:8500/' \
--header 'Content-Type: application/json' \
--header 'sec-fetch-mode: cors' \
--header 'cookie: boooo' \
--data-raw '{
	"jsonrpc":"2.0",
	"method":"eth_getBalance",
	"params":[
		"0x407d73d8a49eeb85d32cf465507dd71d507100c1", 
		"latest"
	],
	"id":1
}'

```

Example log

```
root@3e2a95f89e48:/var/log/nginx# tail -f test.detail.log 
[14/Apr/2022:15:02:09 +0000] "curl/7.68.0" 172.17.0.1 - - "-" 200 40 - POST / HTTP/1.1 {\x0A\x22jsonrpc\x22:\x222.0\x22,\x0A\x22method\x22:\x22eth_getBalance\x22,\x0A\x22params\x22:[\x0A\x220x407d73d8a49eeb85d32cf465507dd71d507100c1\x22, \x0A\x22latest\x22\x0A],\x0A\x22id\x22:1\x0A} - -
[14/Apr/2022:15:03:20 +0000] "curl/7.68.0" 172.17.0.1 - - "-" 200 40 - POST / HTTP/1.1 {\x0A\x22jsonrpc\x22:\x222.0\x22,\x0A\x22method\x22:\x22eth_getBalance\x22,\x0A\x22params\x22:[\x0A\x220x407d73d8a49eeb85d32cf465507dd71d507100c1\x22, \x0A\x22latest\x22\x0A],\x0A\x22id\x22:1\x0A} boooo cors
```