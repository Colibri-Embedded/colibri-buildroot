################################################################################
#
# python-pycurl
#
################################################################################

PYTHON_PYCURL_VERSION = 7_43_0
PYTHON_PYCURL_SOURCE = REL_$(PYTHON_PYCURL_VERSION).tar.gz
PYTHON_PYCURL_SITE = http://github.com/pycurl/pycurl/archive/
PYTHON_PYCURL_LICENSE = MIT
PYTHON_PYCURL_LICENSE_FILES = LICENSE
PYTHON_PYCURL_SETUP_TYPE = distutils

# Make sure dynamic files are generated
define pycurl_gen_files
	$(MAKE1) -C $(@D) gen
endef

PYTHON_PYCURL_ENV = PYCURL_SSL_LIBRARY="openssl"

PYTHON_PYCURL_PRE_BUILD_HOOKS += pycurl_gen_files

$(eval $(python-package))
