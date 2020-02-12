.PHONY: base
base:
	docker build . -t wdt-base --target BASE

.PHONY: deps
deps:
	docker build . -t wdt-deps --target DEPS

.PHONY: release
release:
	docker build . -t wdt --target RELEASE

.PHONY: push
push:
	docker tag wdt tolgaakyuz/wdt:latest
	docker push tolgaakyuz/wdt:latest

.PHONE: receiver
receiver:
	docker run -it --rm \
	  --name wdt-receiver \
	  --network host \
	  --user $(shell id -u):$(shell id -g) \
	  -v $(shell pwd)/data:/data \
	  tolgaakyuz/wdt
