nginx:
  pkg:
    - installed
    - pkgs:
      - nginx
      # things like htpasswd
      - apache2-utils
      # required for proper SSL support
      - ca-certificates

/etc/nginx:
  file.recurse:
    - source: salt://nginx/etc/nginx
    - include_empty: True
    - dir_mode: '0755'
    - file_mode: '0644'
    - template: jinja
    - require:
      - pkg: nginx
    - watch_in:
      - service: nginx_service

# populate nginx resolver config from /etc/resolv.conf
# for using nginx as a proxy
# https://nginx.org/en/docs/http/ngx_http_core_module.html#resolver
nginx_dns_resolver:
  cmd.run:
    - name: (echo "resolver "; cat /etc/resolv.conf |awk '{print $2}' ; echo ";") | tr '\n' ' ' > /etc/nginx/resolver.conf
    - unless: test -f /etc/nginx/resolver.conf && [ "$(stat -c %Y /etc/resolv.conf)" -lt "$(stat -c %Y /etc/nginx/resolver.conf)" ]
    - require:
      - file: /etc/nginx
    - watch_in:
      - service: nginx_service

# protect the ssl dir:
/etc/nginx/ssl:
  file.directory:
    - user: root
    - group: root
    - mode: '0700'
    - recurse:
      - user
      - group
      - mode
    - require:
      - pkg: nginx

# generate DH primes
# https://weakdh.org/sysadmin.html
nginx_dh_primes:
  cmd.run:
    - name: openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048
    - unless: test -f /etc/nginx/ssl/dhparams.pem
    - watch_in:
      - service: nginx_service
    - require:
      - file: /etc/nginx/ssl

# do not restart if config has errors
nginx_test_config:
  cmd.run:
    - name: nginx -t
    - unless: nginx -t
    - require:
      - cmd: nginx_dns_resolver
      - cmd: nginx_dh_primes
      - pkg: nginx
      - file: /etc/nginx

# start or reload nginx service
# reloaded triggered by changed in states that specify this service in "watch_in"
nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - cmd: nginx_test_config
