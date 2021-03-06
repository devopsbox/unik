SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

# When containers change, change this 
CONTAINERVER:=0.1

ifneq ($(CONTAINERVER),)
CONTAINERTAG:=:$(CONTAINERVER)
endif

all: pull ${SOURCES} binary

.PHONY: pull
.PHONY: containers
.PHONY: rump-debugger-qemu
.PHONY: compilers-rump-base-common
.PHONY: compilers-rump-base-hw
.PHONY: compilers-rump-base-xen
.PHONY: compilers-rump-go-hw
.PHONY: compilers-rump-go-hw-no-stub
.PHONY: compilers-rump-go-xen
.PHONY: compilers-rump-nodejs-hw
.PHONY: compilers-rump-nodejs-hw-no-stub
.PHONY: compilers-rump-nodejs-xen
.PHONY: compilers-rump-python3-hw
.PHONY: compilers-rump-python3-hw-no-stub
.PHONY: compilers-rump-python3-xen
.PHONY: compilers-osv-java
.PHONY: compilers
.PHONY: boot-creator
.PHONY: image-creator
.PHONY: vsphere-client
.PHONY: qemu-util
.PHONY: utils
.PHONY: set-container-versions

#pull containers
pull:
	echo "Pullling containers from docker hub"
	docker pull projectunik/vsphere-client$(CONTAINERTAG)
	docker pull projectunik/image-creator$(CONTAINERTAG)
	docker pull projectunik/boot-creator$(CONTAINERTAG)
	docker pull projectunik/qemu-util$(CONTAINERTAG)
	docker pull projectunik/compilers-osv-java$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-go-hw$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-go-hw-no-stub$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-go-xen$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-nodejs-hw$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-nodejs-hw-no-stub$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-nodejs-xen$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-python3-hw$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-python3-hw-no-stub$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-python3-xen$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-base-xen$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-base-hw$(CONTAINERTAG)
	docker pull projectunik/rump-debugger-qemu$(CONTAINERTAG)
	docker pull projectunik/compilers-rump-base-common$(CONTAINERTAG)
#------

#build containers from source
containers: compilers utils
	echo "Built containers from source"

#compilers
compilers: compilers-rump-go-hw compilers-rump-go-xen compilers-rump-nodejs-hw compilers-rump-nodejs-hw-no-stub compilers-rump-nodejs-xen compilers-osv-java compilers-rump-go-hw-no-stub compilers-rump-python3-hw compilers-rump-python3-hw-no-stub compilers-rump-python3-xen

set-container-versions:
	find ./containers -type f -print0 | xargs -0 perl -pi -e 's/FROM projectunik\/(.*):[0-9]\.[0-9]+/FROM projectunik\/$${1}$(CONTAINERTAG)/g'

compilers-rump-base-common: set-container-versions
	cd containers/compilers/rump/base && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.common .

compilers-rump-base-hw: compilers-rump-base-common
	cd containers/compilers/rump/base && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw .

compilers-rump-base-xen: compilers-rump-base-common
	cd containers/compilers/rump/base && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.xen .

compilers-rump-go-hw: compilers-rump-base-hw
	cd containers/compilers/rump/go &&  docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw .

rump-debugger-qemu: compilers-rump-base-hw
	cd containers/debuggers/rump/base &&  docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw .

compilers-rump-go-hw-no-stub: compilers-rump-base-hw
	cd containers/compilers/rump/go && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw.no-stub .

compilers-rump-go-xen: compilers-rump-base-xen
	cd containers/compilers/rump/go && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.xen .

compilers-rump-nodejs-hw: compilers-rump-base-hw
	cd containers/compilers/rump/nodejs && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw .

compilers-rump-nodejs-hw-no-stub: compilers-rump-base-hw
	cd containers/compilers/rump/nodejs && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw.no-stub .

compilers-rump-nodejs-xen: compilers-rump-base-xen
	cd containers/compilers/rump/nodejs && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.xen .

compilers-rump-python3-hw: compilers-rump-base-hw
	cd containers/compilers/rump/python3 && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw .

compilers-rump-python3-hw-no-stub: compilers-rump-base-hw
	cd containers/compilers/rump/python3 && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw.no-stub .

compilers-rump-python3-xen: compilers-rump-base-xen
	cd containers/compilers/rump/python3 && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.xen .

compilers-osv-java: set-container-versions
	cd containers/compilers/osv/java-compiler && GOOS=linux go build && docker build -t projectunik/$@$(CONTAINERTAG) .  && rm java-compiler

debuggers-rump-base-hw: compilers-rump-go-hw
	cd containers/debuggers/rump/base && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile.hw .

#utils
utils: boot-creator image-creator vsphere-client qemu-util

boot-creator: set-container-versions
	cd containers/utils/boot-creator && GO15VENDOREXPERIMENT=1 GOOS=linux go build && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile . && rm boot-creator

image-creator: set-container-versions
	cd containers/utils/image-creator && GO15VENDOREXPERIMENT=1 GOOS=linux go build && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile . && rm image-creator

vsphere-client: set-container-versions
	cd containers/utils/vsphere-client && mvn package && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile . && rm -rf target

qemu-util: set-container-versions
	cd containers/utils/qemu-util && docker build -t projectunik/$@$(CONTAINERTAG) -f Dockerfile .

#------

#binary

BINARY=unik

# don't override if provided already
ifeq (,$(TARGET_OS))
    UNAME:=$(shell uname)
	ifeq ($(UNAME),Linux)
		TARGET_OS:=linux
	else ifeq ($(UNAME),Darwin)
		TARGET_OS:=darwin
	endif
endif

binary: ${SOURCES}
ifeq (,$(TARGET_OS))
	echo "Unknown platform $(UNAME)"
	echo "Unknown platform $(TARGET_OS)"
	exit 1
endif
	echo Building for platform $(UNAME)
	docker build -t projectunik/$@ -f Dockerfile .
	mkdir -p ./_build
	docker run --rm -v $(shell pwd)/_build:/opt/build -e TARGET_OS=$(TARGET_OS) -e CONTAINERVER=$(CONTAINERVER) projectunik/$@
	#docker rmi -f projectunik/$@
	echo "Install finished! UniK binary can be found at $(shell pwd)/_build/unik"
#----

# local build - useful if you have development env setup. if not - use binary! (this can't depend on binary as binary depends on it via the Dockerfile)
localbuild: instance-listener/bindata/instance_listener_data.go  ${SOURCES}
	 GOOS=${TARGET_OS} go build -ldflags "-X github.com/emc-advanced-dev/unik/pkg/util.containerVer=$(CONTAINERVER)" .

instance-listener/bindata/instance_listener_data.go:
	go-bindata -o instance-listener/bindata/instance_listener_data.go --ignore=instance-listener/bindata/ instance-listener/... && \
	perl -pi -e 's/package main/package bindata/g' instance-listener/bindata/instance_listener_data.go
    
#clean up
.PHONY: uninstall remove-containers clean

uninstall:
	rm $(which ${BINARY})

remove-containers:
	-docker rmi -f projectunik/binary$(CONTAINERTAG)
	-docker rmi -f projectunik/vsphere-client$(CONTAINERTAG)
	-docker rmi -f projectunik/image-creator$(CONTAINERTAG)
	-docker rmi -f projectunik/boot-creator$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-osv-java$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-go-xen$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-go-hw$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-go-hw-no-stub(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-nodejs-hw$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-nodejs-hw-no-stub$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-nodejs-xen$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-python3-hw$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-python3-hw-no-stub$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-python3-xen$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-base-xen$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-base-hw$(CONTAINERTAG)
	-docker rmi -f projectunik/rump-debugger-qemu$(CONTAINERTAG)
	-docker rmi -f projectunik/compilers-rump-base-common$(CONTAINERTAG)
	-docker rmi -f debuggers-rump-base-hw$(CONTAINERTAG)

clean:
	rm -rf ./_build
#---
