docker run --rm --name test-nginx -p 8500:8500 -v `pwd`/nginx.conf:/etc/nginx/nginx.conf:ro -v `pwd`/default.conf:/etc/nginx/conf.d/default.conf:ro nginx