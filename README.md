# salt-nginx

Saltstack states to set up an nginx server.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-nginx.git salt/nginx
    
The states are independent of their actual location in the state file tree, so you may replace `salt/nginx` with a location of your choice.

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
