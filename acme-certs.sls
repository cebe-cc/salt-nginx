# obtain acme ssl certs (letsencrypt)
#
# If pillar defines certificates via pillar.ssl.acme-certs
# a certificate is issued with these domains.
#
# Example Pillar YAML:

# ssl:
#   acme-certs:
#     - domains:
#         - example.com
#         - www.example.com
#       webdir: /var/www/example.com

# The webdir option is optional, defaults to /var/www/html
#
# If no configuration is defined in pillar, no certificate is issued.
#
# You may use the state "acme_cert_{ssl_domain}" in other states requisites,
# where {ssl_domain} refers to the first domain specified in "domains" or the 
# hostname if no pillar is specified.
#

include:
  - .acme

{% if pillar.ssl['acme-certs'] is defined %}
{% for cert in pillar.ssl['acme-certs'] %}

{% set ssl_domain = cert.domains|first %}
{% set ssl_domains = '-d ' ~ cert.domains|join(' -d ') %}
{% if cert.webdir is defined %}
  {% set ssl_webdir = cert.webdir %}
{% else %}
  {% set ssl_webdir = '/var/www/html' %}
{% endif %}

acme_cert_{{ ssl_domain }}:
  cmd.run:
    - name: 'if (curl -s localhost>/dev/null); then /var/lib/acme/acme.sh --issue --home /var/lib/acme {{ ssl_domains }} -w {{ ssl_webdir }} ; else /var/lib/acme/acme.sh --issue --home /var/lib/acme {{ ssl_domains }} --standalone ; fi'
    - unless: test -f /var/lib/acme/{{ ssl_domain }}/{{ ssl_domain }}.cer
    - require:
        - cmd: acme_install
        - pkg: acme_dependencies

{% endfor %}
{% endif %}
