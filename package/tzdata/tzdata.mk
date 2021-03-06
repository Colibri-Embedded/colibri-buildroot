################################################################################
#
# tzdata
#
################################################################################

TZDATA_VERSION = 2014d
TZDATA_SOURCE = tzdata$(TZDATA_VERSION).tar.gz
TZDATA_SITE = ftp://ftp.iana.org/tz/releases
TZDATA_DEPENDENCIES = host-tzdata
HOST_TZDATA_DEPENDENCIES = host-zic
TZDATA_LICENSE = Public domain

TZDATA_DEFAULT_ZONELIST = \
	africa antarctica asia australasia backward etcetera \
	europe factory northamerica pacificnew southamerica

ifeq ($(call qstrip,$(BR2_TARGET_TZ_ZONELIST)),default)
TZDATA_ZONELIST = $(TZDATA_DEFAULT_ZONELIST)
else
TZDATA_ZONELIST = $(call qstrip,$(BR2_TARGET_TZ_ZONELIST))
endif

TZDATA_LOCALTIME = $(call qstrip,$(BR2_TARGET_LOCALTIME))

# No need to extract for target, we're using the host-installed files
TZDATA_EXTRACT_CMDS =

define TZDATA_INSTALL_TARGET_CMDS
	$(TZDATA_FAKEROOT) $(INSTALL) -d -m 0755 $(TZDATA_TARGET_DIR)/usr/share/zoneinfo
	$(TZDATA_FAKEROOT) cp -a $(HOST_DIR)/usr/share/zoneinfo/* $(TZDATA_TARGET_DIR)/usr/share/zoneinfo
	for zone in $(TZDATA_TARGET_DIR)/usr/share/zoneinfo/posix/*; do                 \
	    $(TZDATA_FAKEROOT) ln -sfn "/usr/share/zoneinfo/posix/$${zone##*/}" "$(TZDATA_TARGET_DIR)/usr/share/zoneinfo/$${zone##*/}";  \
	done
	if [ -n "$(TZDATA_LOCALTIME)" ]; then                           \
	    if [ ! -f $(TZDATA_TARGET_DIR)/usr/share/zoneinfo/$(TZDATA_LOCALTIME) ]; then \
	        printf "Error: '%s' is not a valid timezone, check your BR2_TARGET_LOCALTIME setting\n" \
	               "$(TZDATA_LOCALTIME)";                           \
	        exit 1;                                                 \
	    fi;                                                         \
	    $(TZDATA_FAKEROOT)  mkdir -p $(TZDATA_TARGET_DIR)/etc; \
	    $(TZDATA_FAKEROOT)  ln -sf ../usr/share/zoneinfo/$(TZDATA_LOCALTIME) $(TZDATA_TARGET_DIR)/etc/localtime; \
	    $(TZDATA_FAKEROOT)  echo "$(TZDATA_LOCALTIME)" > $(TZDATA_TARGET_DIR)/etc/timezone;                      \
	fi
endef

define HOST_TZDATA_EXTRACT_CMDS
	gzip -d -c $(DL_DIR)/$(TZDATA_SOURCE) \
		| $(TAR) --strip-components=0 -C $(@D) -xf -
endef

define HOST_TZDATA_BUILD_CMDS
	(cd $(@D); \
		for zone in $(TZDATA_ZONELIST); do \
			$(ZIC) -d _output/posix -y yearistype.sh $$zone; \
			$(ZIC) -d _output/right -L leapseconds -y yearistype.sh $$zone; \
		done; \
	)
endef

define HOST_TZDATA_INSTALL_CMDS
	$(INSTALL) -d -m 0755 $(HOST_DIR)/usr/share/zoneinfo
	cp -a $(@D)/_output/* $(@D)/*.tab $(HOST_DIR)/usr/share/zoneinfo
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
