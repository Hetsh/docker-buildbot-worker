# Work In Progress

# Buildbot Worker
Super small and easy to set up Buildbot Worker.

## Running the server
```bash
docker run --detach --name buildbot-worker hetsh/buildbot-worker
```

## Stopping the container
```bash
docker stop buildbot-worker
```

## Creating persistent storage
```bash
MP="/path/to/storage"
mkdir -p "$MP"
chown -R 1378:1378 "$MP"
```
`1378` is the numerical id of the user running the server (see Dockerfile).
Start the server with the additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/buildbot-worker ...
```

## Configuration
The client can be configured via config file.
[This Website](https://buildbot-worker.com/wizard) helps you generate one.
Just place the `config.json` into the storage directory and you are good to go.

## Automate startup and shutdown via systemd
The systemd unit can be found in my GitHub [repository](https://github.com/Hetsh/docker-buildbot-worker).
```bash
systemctl enable buildbot-worker.service --now
```
By default, the systemd service assumes `/apps/buildbot-worker` for persistent storage and `/etc/localtime` for timezone.
Since this is a personal systemd unit file, you might need to adjust some parameters to suit your setup.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-buildbot-worker)).
Please feel free to ask questions, file an issue or contribute to it.