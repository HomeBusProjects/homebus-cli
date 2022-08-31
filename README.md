# homebus-cli

Command line interface to Homebus. The initial version is extremely limited; it lets you login and stashes an auth token that allows other applications to provision themselves.

## Usage

On its first run, `homebus-snmp` needs to know how to find the HomeBus provisioning server.

```
bundle exec homebus-cli -b homebus-server-IP-or-domain-name -P homebus-server-port username [password]
```

The port will usually be 80 (its default value). The server will default to homebus.io

Once it's provisioned it stores its provisioning information in `.homebus.json`. This file should be protected; the auth token in it will allow devices to join your network.
