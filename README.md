### Receiver

```
docker run -it --rm --name wdt-receiver --network host --user $(id -u):$(id -g) -v $(pwd)/data:/data tolgaakyuz/wdt
```

### Sender

```
docker run --rm --name wdt-sender --network host --user $(id -u):$(id -g) -v $(pwd):/data tolgaakyuz/wdt -- wdt -connection_url=""
```
