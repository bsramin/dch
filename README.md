![DCH](docs/logo_dch.png)

DCH is an Helper to simplify the use of `docker compose` in the development environment only.

## Installation

Prerequisites:
- docker 18.02.0+
- docker-compose 1.20.0+

### Docker Compose

Place your docker-compose.yml in the `/project` directory

The commands available for the management of containers are:

```
    bin/up        # Activate containers
    bin/down      # Switch off containers
    bin/restart   # Restart containers
    bin/status    # Verifies the status of containers, and images
    bin/run       # Executes a command inside one of the containers
    bin/open      # Opens a bash shell (or zsh shell) inside one of the containers (if provided)
    bin/build     # Container construction
    bin/setup     # Executes maintenance commands
    bin/project   # If the project provides for it, it executes commands linked to the project itself
```

### (mac only) NFS Server

To bypass the problem of slow volumes shared with osxfs, Docker 18.03.0-ce-mac59 has implemented the possibility of sharing with NFS.

The NFS volume is declared in the file `docker-compose.yml` as follows

```
  app-data:
    driver: local
    driver_opts:
      type: nfs
      o: rw,async,noatime,rsize=32768,wsize=32768,proto=tcp,nfsvers=3,addr=host.docker.internal
      device: ":${APP_PATH}"      
```

To start the service on the host mac edit the file `/etc/exports` and adding the line

```"/Users" localhost -alldirs -mapall=501:20```

Add this line to the `/etc/nfs.conf` file:

```nfs.server.mount.require_resv_port = 0```

And finally start/restart the nfs service

```sudo nfsd restart```

### Proxy configuration tld .localhost to docker

As an alternative to configuring the individual domains in the /etc/hosts file, you can manage an entire tld addressed to Docker

#### macOS

Install dnsmasq (needs homebrew [see https://brew.sh/index_en.html])

    brew install dnsmasq

Edit the configuration file `/usr/local/etc/dnsmasq.conf`

    address=/.localhost/127.0.0.1
    listen-address=127.0.0.1

Start the service

    sudo brew services start dnsmasq

Configure the DNS resolution

    sudo mkdir -p /etc/resolver
    sudo tee /etc/resolver/localhost > /dev/null <<EOF
    nameserver 127.0.0.1
    domain localhost
    search_order 1
    EOF

#### Linux 

Install dnsmasq (for Debian and it's derivatives, for other distro, use the package manager of your distribution)

    sudo apt-get install dnsmasq
    
Create the file `/etc/dnsmasq.d/localhost-tld` containing:    

    local=/localhost/
    address=/localhost/127.0.0.1
    
And restart the service

    sudo /etc/init.d/dnsmasq restart
    
### Reverse proxy
##### (optional)

DCH includes an automatic reverse proxy service (thanks to [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)) to be able to work with multiple domains, on multiple containers/domains of DCH and always keeping port 80 (which automatically redirects to the actual container port, different from 80).

In the project, in `docker-compose.yml` to the definition of the networks add

```
networks:
  reverse-proxy:
    external:
      name: dch-reverse-proxy
``` 

and in the definition of the webserver container (apache, nginx, ...), always in `docker-compose.yml` attach to the network

```
networks:
    (....)
    reverse-proxy:
```

and add the `VIRTUAL_HOST` and `VIRTUAL_PORT` as environment variables

```
environment:
  - VIRTUAL_HOST=${APP_HOST}
  - VIRTUAL_PORT=[service exposed port, For example: in "ports: 8080:80" write "80" here]
```

and then start with `bin/up -r` command.

You can also use it on multiple services at the same time, remembering to do the above for everyone

## SAMPLE

Look at the [example project](https://github.com/feries/dch-project-sample) (LEMP Stack).

# LICENSE
    
The MIT License (MIT)

Copyright (c) 2018 Feries S.r.l.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
