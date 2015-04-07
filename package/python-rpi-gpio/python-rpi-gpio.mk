################################################################################
#
# python-rpi-gpio
#
################################################################################

PYTHON_RPI_GPIO_VERSION = 0.5.7
PYTHON_RPI_GPIO_SOURCE = RPi.GPIO-$(PYTHON_RPI_GPIO_VERSION).tar.gz
PYTHON_RPI_GPIO_SITE = https://pypi.python.org/packages/source/R/RPi.GPIO
PYTHON_RPI_GPIO_LICENSE = Python Software Foundation License
PYTHON_RPI_GPIO_LICENSE_FILES = LICENSE.txt
PYTHON_RPI_GPIO_SETUP_TYPE = distutils

$(eval $(python-package))
