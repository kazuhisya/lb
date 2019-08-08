
SRCS:=$(wildcard *.go)
VERSION := $(shell grep -oP '(?<=").+(?=")' version.go)

lb: $(SRCS)
	go build

deps:
	go get -u github.com/urfave/cli
	go get -u github.com/satori/go.uuid
	go get -u gopkg.in/ldap.v3

clean:
	rm -rf lb

install:
	mkdir -p $(DESTDIR)/usr/bin/
	install -m 755 lb $(DESTDIR)/usr/bin/

rpm:
	mkdir -p ./dist/{BUILD,RPMS,SPECS,SOURCES,SRPMS,install}
	git archive --format=tar --prefix=lb-$(VERSION)/ HEAD | \
		gzip > ./dist/SOURCES/$(VERSION).tar.gz
	cat lb.spec.in | \
		LB_VERSION="$(VERSION)" \
		envsubst '$$LB_VERSION' > ./dist/SPECS/lb.spec
	rpmbuild -ba \
		--define "_topdir $(PWD)/dist" \
		--define "buildroot $(PWD)/dist/install" \
		--clean \
		./dist/SPECS/lb.spec
