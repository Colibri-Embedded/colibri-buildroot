################################################################################
#
# python-picamera
#
################################################################################

#https://github.com/waveform80/picamera/archive/release-1.12.tar.gz

PYTHON_PICAMERA_VERSION = 1.12
PYTHON_PICAMERA_SOURCE = release-$(PYTHON_PICAMERA_VERSION).tar.gz
PYTHON_PICAMERA_SITE = https://github.com/waveform80/picamera/archive
PYTHON_PICAMERA_LICENSE = BSD-3c
PYTHON_PICAMERA_LICENSE_FILES = LICENSE.txt
PYTHON_PICAMERA_SETUP_TYPE = setuptools

$(eval $(python-package))
