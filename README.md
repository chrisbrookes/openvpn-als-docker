# openvpn-als-docker
Dockerised openvpn-asl / adito / sslexplorer

## Usage
This set up uses docker-compose. It will probably run as a conventional docker
set up, with careful configuration of volumes.

1. Copy the [example docker-compose.yml](docker-compose-example.yml) to your own
`docker-compose.yml`.

1. Build:
 ```
docker-compose build
 ```

1. Execute the install, and :
 ```
docker-compose up install
 ```

1. Use a browser to go to http://localhost:28080 to run
   through the initial config

1. After the install container has exited, execute the main container
 ```
docker-compose up -d run
 ```

1. OpenVpn ALS should be available at https://localhost:443 (assuming it was
configured to this)

* Note that the two services in the compose file cannot be run at the same time.
* Tested with Docker 1.11.2. Will probably work with 1.9+.

### Applications
#### RDP
There are a number of RDP (Windows Remote Desktop Protocol) extensions (applications).
The RDPs that still (Sep 2016) seem to work ok are:

* `adito-application-properjavardp/adito-application-properjavardp.zip`
* `adito-application-nativerdp/adito-application-nativerdp.zip`

## Backing up
To back up the configuration, the following should be archived:

* db folder: `/opt/openvpn-als/adito/db`
* conf folder: `/opt/openvpn-als/adito/conf` - mapped to host by default as:
  `/var/lib/docker/volumes/dockeropenvpnals_conf/_data`
  * Specifically you should backup `repository/keystore/default.keystore.jks` and
    `webserver.properties` (relative from the `/opt/openvpn-als/adito/conf` folder).
    If these files are backed up, it is possible to recreate the container
    without necessarily having to run the install. Simply copy these files to their
    respective locations in the new conf volume (note you may have to run
    the container once to force compose to create the volume!).

-------------------------------------------------------------------------------

## Notes
#### Image
This docker set up uses code from https://github.com/chrisbrookes/openvpn-als.git (main
src) and https://github.com/chrisbrookes/openvpn-als-applications.git (extensions).
You should be able to change this by providing ARGs when building the docker image
(see the [Dockerfile](Dockerfile)), but this has not been tested.

#### Conf volume
OpenVPN-ALS has poor separation of build and runtime settings. The adito/conf
folder has configuration files that are in the codebase repo which isn't ideal.
In this docker-compose set up, conf is set up as a volume that is not specifically
mapped to the host (but is available on the host at `/var/lib/docker/volumes/dockeropenvpnals_conf/_data`).
If this volume is specifically mapped to a folder on the host, the host folder will
completely replace the prepared folder in the image (as per docker design), which
means the app will fail to start (unless all the conf files do happen to be
contained in the host mapped conf folder).

#### Upgrades
Currently there is no forethought around database upgrades, or upgrades that involve
the conf volume. It's unlikely at this point (given this project is effectively dormant)
that there will be any need to take this into account.