# salt-nginx

Saltstack states to set up an nginx server.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-nginx.git salt/nginx
    
> **Note:** The states are currently not independent of their location in the state file tree, so you must place them at `salt://nginx`.

## Supported OSs

- Debian
  - 8, `jessie`
  - 9, `stretch`

## Features

- Basic Nginx Setup
- SSL
  - setup DH primes according to https://weakdh.org/sysadmin.html
  - configure OCSP stapling
  - set HSTS header
  - Automatic registration of Letsencrypt certificates via acme.sh
