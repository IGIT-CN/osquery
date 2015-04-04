PLATFORM := $(shell uname -s)
VERSION := $(shell git describe --tags HEAD --always)
MAKE = make
ifeq ($(PLATFORM),Darwin)
	BUILD_DIR=darwin
else ifeq ($(PLATFORM),FreeBSD)
	BUILD_DIR=freebsd
	MAKE=gmake
else
  DISTRO := $(shell if [[ -f "/etc/lsb-release" ]]; then echo "Ubuntu"; fi)
  DISTRO := $(shell if [ -n `cat /etc/redhat-release | grep -o "CentOS"` ]; then echo "Centos"; fi)
  DISTRO := $(shell if [ -n `cat /etc/redhat-release | grep -o "Red Hat Enterprise"` ]; then echo "RHEL"; fi)
  ifeq ($(DISTRO),Centos)
    BUILD_DIR := $(shell cat /etc/redhat-release | grep -o "release [6-7]" | sed 's/release /centos/g')
  endif
  ifeq ($(DISTRO),RHEL)
    BUILD_DIR := $(shell cat /etc/redhat-release | grep -o "release [6-7]" | sed 's/release /rhel/g')
  endif
  ifeq ($(DISTRO),Ubuntu)
    BUILD_DIR := $(shell lsb_release -sc)
  endif
endif

DEFINES := CTEST_OUTPUT_ON_FAILURE=1

all: .setup
	cd build/$(BUILD_DIR) && cmake ../.. && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

debug: .setup
	cd build/$(BUILD_DIR) && DEBUG=True cmake ../../ && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_debug: .setup
	cd build/$(BUILD_DIR) && DEBUG=True cmake ../../ && \
	  $(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

analyze: .setup
	cd build/$(BUILD_DIR) && ANALYZE=True cmake ../../ && \
	  $(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

sanitize: .setup
	cd build/$(BUILD_DIR) && SANITIZE=True cmake ../../ && \
	  $(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

sdk: .setup
	cd build/$(BUILD_DIR) && SDK=True cmake ../../ && \
	  $(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_sdk: .setup
	cd build/$(BUILD_DIR) && SDK=True cmake ../../ && \
	  $(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

debug_sdk: .setup
	cd build/$(BUILD_DIR) && SDK=True DEBUG=True cmake ../../ && \
	  $(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_debug_sdk: .setup
	cd build/$(BUILD_DIR) && SDK=True DEBUG=True cmake ../../ && \
	  $(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

deps: .setup
	./tools/provision.sh build build/$(BUILD_DIR)

distclean:
	rm -rf .sources build/$(BUILD_DIR) doxygen/html doxygen/latex
ifeq ($(PLATFORM),Linux)
		rm -rf build/linux
endif

.setup:
	export CTEST_OUTPUT_ON_FAILURE=1
	mkdir -p build/$(BUILD_DIR)
ifeq ($(PLATFORM),Linux)
		ln -snf $(BUILD_DIR) build/linux
endif

package:
	# Alias for packages (do not use CPack)
	cd build/$(BUILD_DIR) && cmake ../../ && \
		$(DEFINES) $(MAKE) packages --no-print-directory $(MAKEFLAGS)

%::
	cd build/$(BUILD_DIR) && cmake ../.. && \
	  $(DEFINES) $(MAKE) --no-print-directory $@
