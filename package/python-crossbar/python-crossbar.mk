################################################################################
#
# python-crossbar
#
################################################################################

PYTHON_CROSSBAR_VERSION = 0.15.0
PYTHON_CROSSBAR_SOURCE = v$(PYTHON_CROSSBAR_VERSION).tar.gz
PYTHON_CROSSBAR_SITE = https://github.com/crossbario/crossbar/archive
PYTHON_CROSSBAR_LICENSE = MIT
# README.rst refers to the file "LICENSE" but it's not included
PYTHON_CROSSBAR_SETUP_TYPE = setuptools
PYTHON_CROSSBAR_DEPENDENCIES = python-autobahn python-setproctitle python-setuptools \
	python-pyasn1 python-pyopenssl python-service-identity \
	python-treq python-requests python-pynacl python-cbor python-pyubjson python-lmdb python-u-msgpack \
	python-psutil python-shutilwhich python-pygments python-jinja2 python-pytrie python-click python-netaddr

$(eval $(python-package))
