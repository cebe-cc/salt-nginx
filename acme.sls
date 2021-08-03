acme_dependencies:
  pkg.installed:
   - pkgs:
      - curl
      - git

acme_git:
  git.latest:
    - name: https://github.com/Neilpang/acme.sh.git
    - rev: 2.8.5 # TODO install a process to upgrade this on a regular basis
    - target: /opt/acme.sh
    - force_reset: True
    - require:
        - pkg: acme_dependencies

acme_install:
  cmd.run:
    - name: 'mkdir -p /var/lib/acme && cd /opt/acme.sh && ./acme.sh --install --nocron --home /var/lib/acme'
    - onchanges:
        - git: acme_git

# cronjob to update certs
acme_cert_cron:
  cron.present:
    - identifier: acme_cert_cron
    - name: '/var/lib/acme/acme.sh --cron --home "/var/lib/acme" --reloadcmd "systemctl reload nginx" > /var/log/acme.log'
    - minute: random
    - hour: 3
    - require:
        - cmd: acme_install

# TODO acme logrotate

