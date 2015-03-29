################################################################################
#
# opentyrian-data
#
################################################################################

OPENTYRIAN_DATA_VERSION = 2.1
OPENTYRIAN_DATA_SITE = http://www.camanis.net/opentyrian
OPENTYRIAN_DATA_SOURCE = tyrian21.zip
OPENTYRIAN_DATA_LICENSE = Freeware

define OPENTYRIAN_DATA_EXTRACT_CMDS
	$(UNZIP) -d $(@D) $(DL_DIR)/$(OPENTYRIAN_DATA_SOURCE)
endef

define OPENTYRIAN_DATA_INSTALL_TARGET_CMDS
	mkdir -p $(OPENTYRIAN_DATA_TARGET_DIR)/usr/share/opentyrian/data/
	cp $(@D)/tyrian21/* $(OPENTYRIAN_DATA_TARGET_DIR)/usr/share/opentyrian/data/
	rm -f $(OPENTYRIAN_DATA_TARGET_DIR)/usr/share/opentyrian/data/*.doc
	rm -f $(OPENTYRIAN_DATA_TARGET_DIR)/usr/share/opentyrian/data/*.exe
endef

$(eval $(generic-package))
