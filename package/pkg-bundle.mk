################################################################################
# Bundle package infrastructure
#
# This file implements an infrastructure that eases development of
# package .mk files. It should be used for packages that do not rely
# on a well-known build system for which Buildroot has a dedicated
# infrastructure (so far, Buildroot has special support for
# autotools-based and CMake-based packages).
#
# See the Buildroot documentation for details on the usage of this
# infrastructure
#
# In terms of implementation, this generic infrastructure requires the
# .mk file to specify:
#
#   1. Metadata information about the package: name, version,
#      download URL, etc.
#
#   2. Description of the commands to be executed to configure, build
#      and install the package
################################################################################

################################################################################
# Helper functions to catch start/end of each step
################################################################################

# Those two functions are called by each step below.
# They are responsible for calling all hooks defined in
# $(GLOBAL_INSTRUMENTATION_HOOKS) and pass each of them
# three arguments:
#   $1: either 'start' or 'end'
#   $2: the name of the step
#   $3: the name of the package

# Start step
# $1: step name

################################################################################
# inner-generic-bundle-package -- generates the make targets needed to build a
# generic package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name, including a HOST_ prefix
#             for host packages
#  argument 3 is the uppercase package name, without the HOST_ prefix
#             for host packages
#  argument 4 is the type (target or host)
#
# Note about variable and function references: inside all blocks that are
# evaluated with $(eval), which includes all 'inner-xxx-package' blocks,
# specific rules apply with respect to variable and function references.
# - Numbered variables (parameters to the block) can be referenced with a single
#   dollar sign: $(1), $(2), $(3), etc.
# - pkgdir and pkgname should be referenced with a single dollar sign too. These
#   functions rely on 'the most recently parsed makefile' which is supposed to
#   be the package .mk file. If we defer the evaluation of these functions using
#   double dollar signs, then they may be evaluated too late, when other
#   makefiles have already been parsed. One specific case is when $$(pkgdir) is
#   assigned to a variable using deferred evaluation with '=' and this variable
#   is used in a target rule outside the eval'ed inner block. In this case, the
#   pkgdir will be that of the last makefile parsed by buildroot, which is not
#   the expected value. This mechanism is for example used for the TARGET_PATCH
#   rule.
# - All other variables should be referenced with a double dollar sign:
#   $$(TARGET_DIR), $$($(2)_VERSION), etc. Also all make functions should be
#   referenced with a double dollar sign: $$(subst), $$(call), $$(filter-out),
#   etc. This rule ensures that these variables and functions are only expanded
#   during the $(eval) step, and not earlier. Otherwise, unintuitive and
#   undesired behavior occurs with respect to these variables and functions.
#
################################################################################

define inner-generic-bundle-package

# Define default values for various package-related variables, if not
# already defined. For some variables (version, source, site and
# subdir), if they are undefined, we try to see if a variable without
# the HOST_ prefix is defined. If so, we use such a variable, so that
# this information has only to be specified once, for both the
# target and host packages of a given .mk file.

$(2)_TYPE           =  $(4)
$(2)_NAME			=  $(1)
$(2)_RAWNAME		=  $$(patsubst host-%,%,$(1))
$(2)_TARGET_DIR		=  $$(PACKAGES_DIR)/$(1)
$(2)_TARGET_ARCHIVE	=  $$(PACKAGES_DIR)/$(1).tar

# Fakeroot 

ifndef $(2)_FAKEROOT
 ifdef $(3)_FAKEROOT
  $(2)_FAKEROOT = $$($(3)_FAKEROOT) -s $$(@D)/.fakeroot_env -i $$(@D)/.fakeroot_env
 else
  $(2)_FAKEROOT ?= $$(FAKEROOT) -s $$(@D)/.fakeroot_env -i $$(@D)/.fakeroot_env
 endif
endif

#$(2)_FAKEROOT_ENV	= -s $$(@D)/.fakeroot_env -i $$(@D)/.fakeroot_env

# Keep the package version that may contain forward slashes in the _DL_VERSION
# variable, then replace all forward slashes ('/') by underscores ('_') to
# sanitize the package version that is used in paths, directory and file names.
# Forward slashes may appear in the package's version when pointing to a
# version control system branch or tag, for example remotes/origin/1_10_stable.
ifndef $(2)_VERSION
 ifdef $(3)_VERSION
  $(2)_DL_VERSION := $$(strip $$($(3)_VERSION))
  $(2)_VERSION := $$(subst /,_,$$(strip $$($(3)_VERSION)))
 else
  $(2)_VERSION = undefined
  $(2)_DL_VERSION = undefined
 endif
else
  $(2)_DL_VERSION := $$(strip $$($(2)_VERSION))
  $(2)_VERSION := $$(strip $$(subst /,_,$$($(2)_VERSION)))
endif

$(2)_BASE_NAME	=  $(1)-$$($(2)_VERSION)
$(2)_DL_DIR	=  $$(DL_DIR)/$$($(2)_BASE_NAME)
$(2)_DIR	=  $$(BUILD_DIR)/$$($(2)_BASE_NAME)

ifndef $(2)_SUBDIR
 ifdef $(3)_SUBDIR
  $(2)_SUBDIR = $$($(3)_SUBDIR)
 else
  $(2)_SUBDIR ?=
 endif
endif

$(2)_SRCDIR		       = $$($(2)_DIR)/$$($(2)_SUBDIR)
$(2)_BUILDDIR		       ?= $$($(2)_SRCDIR)

ifneq ($$($(2)_OVERRIDE_SRCDIR),)
$(2)_VERSION = custom
endif

ifndef $(2)_SOURCE
 ifdef $(3)_SOURCE
  $(2)_SOURCE = $$($(3)_SOURCE)
 else
  $(2)_SOURCE			?= $$($(2)_RAWNAME)-$$($(2)_VERSION).tar.gz
 endif
endif

ifndef $(2)_PATCH
 ifdef $(3)_PATCH
  $(2)_PATCH = $$($(3)_PATCH)
 endif
endif

ifndef $(2)_SITE
 ifdef $(3)_SITE
  $(2)_SITE = $$($(3)_SITE)
 endif
endif

ifndef $(2)_SITE_METHOD
 ifdef $(3)_SITE_METHOD
  $(2)_SITE_METHOD = $$($(3)_SITE_METHOD)
 else
	# Try automatic detection using the scheme part of the URI
	$(2)_SITE_METHOD = $$(call geturischeme,$$($(2)_SITE))
 endif
endif

ifeq ($$($(2)_SITE_METHOD),local)
ifeq ($$($(2)_OVERRIDE_SRCDIR),)
$(2)_OVERRIDE_SRCDIR = $$($(2)_SITE)
endif
endif

ifndef $(2)_LICENSE
 ifdef $(3)_LICENSE
  $(2)_LICENSE = $$($(3)_LICENSE)
 endif
endif

$(2)_LICENSE			?= unknown

ifndef $(2)_LICENSE_FILES
 ifdef $(3)_LICENSE_FILES
  $(2)_LICENSE_FILES = $$($(3)_LICENSE_FILES)
 endif
endif

ifndef $(2)_REDISTRIBUTE
 ifdef $(3)_REDISTRIBUTE
  $(2)_REDISTRIBUTE = $$($(3)_REDISTRIBUTE)
 endif
endif

$(2)_REDISTRIBUTE		?= YES

# When a target package is a toolchain dependency set this variable to
# 'NO' so the 'toolchain' dependency is not added to prevent a circular
# dependency
$(2)_ADD_TOOLCHAIN_DEPENDENCY	?= YES

ifeq ($(4),host)
$(2)_DEPENDENCIES ?= $$(filter-out  host-toolchain $(1),\
	$$(patsubst host-host-%,host-%,$$(addprefix host-,$$($(3)_DEPENDENCIES))))
endif
ifeq ($(4),target)
ifeq ($$($(2)_ADD_TOOLCHAIN_DEPENDENCY),YES)
$(2)_DEPENDENCIES += toolchain
endif
endif

ifeq ($(4),target)
$(2)_DEPENDENCIES += host-fakeroot
endif

# Eliminate duplicates in dependencies
$(2)_FINAL_DEPENDENCIES = $$(sort $$($(2)_DEPENDENCIES))

$(2)_INSTALL_STAGING		?= NO
$(2)_INSTALL_IMAGES		?= NO
$(2)_INSTALL_TARGET		?= YES
$(2)_ARCHIVE_TARGET		?= YES

# define sub-target stamps
$(2)_TARGET_INSTALL_TARGET =	$$($(2)_DIR)/.stamp_target_installed
$(2)_TARGET_INSTALL_STAGING =	$$($(2)_DIR)/.stamp_staging_installed
$(2)_TARGET_INSTALL_IMAGES =	$$($(2)_DIR)/.stamp_images_installed
$(2)_TARGET_INSTALL_HOST =      $$($(2)_DIR)/.stamp_host_installed
$(2)_TARGET_ARCHIVE_TARGET =	$$($(2)_DIR)/.stamp_target_archived
$(2)_TARGET_BUILD =		$$($(2)_DIR)/.stamp_built
$(2)_TARGET_CONFIGURE =		$$($(2)_DIR)/.stamp_configured
$(2)_TARGET_RSYNC =	        $$($(2)_DIR)/.stamp_rsynced
$(2)_TARGET_RSYNC_SOURCE =      $$($(2)_DIR)/.stamp_rsync_sourced
$(2)_TARGET_PATCH =		$$($(2)_DIR)/.stamp_patched
$(2)_TARGET_EXTRACT =		$$($(2)_DIR)/.stamp_extracted
$(2)_TARGET_SOURCE =		$$($(2)_DIR)/.stamp_downloaded
$(2)_TARGET_DIRCLEAN =		$$($(2)_DIR)/.stamp_dircleaned

# default extract command
$(2)_EXTRACT_CMDS ?= \
	$$(if $$($(2)_SOURCE),$$(INFLATE$$(suffix $$($(2)_SOURCE))) $$(DL_DIR)/$$($(2)_SOURCE) | \
	$$(TAR) $$(TAR_STRIP_COMPONENTS)=1 -C $$($(2)_DIR) $$(TAR_OPTIONS) -)

# pre/post-steps hooks
$(2)_PRE_DOWNLOAD_HOOKS         ?=
$(2)_POST_DOWNLOAD_HOOKS        ?=
$(2)_PRE_EXTRACT_HOOKS          ?=
$(2)_POST_EXTRACT_HOOKS         ?=
$(2)_PRE_RSYNC_HOOKS            ?=
$(2)_POST_RSYNC_HOOKS           ?=
$(2)_PRE_PATCH_HOOKS            ?=
$(2)_POST_PATCH_HOOKS           ?=
$(2)_PRE_CONFIGURE_HOOKS        ?=
$(2)_POST_CONFIGURE_HOOKS       ?=
$(2)_PRE_BUILD_HOOKS            ?=
$(2)_POST_BUILD_HOOKS           ?=
$(2)_PRE_INSTALL_HOOKS          ?=
$(2)_POST_INSTALL_HOOKS         ?=
$(2)_PRE_INSTALL_STAGING_HOOKS  ?=
$(2)_POST_INSTALL_STAGING_HOOKS ?=
$(2)_PRE_INSTALL_TARGET_HOOKS   ?=
$(2)_POST_INSTALL_TARGET_HOOKS  ?=
$(2)_PRE_INSTALL_IMAGES_HOOKS   ?=
$(2)_POST_INSTALL_IMAGES_HOOKS  ?=
$(2)_PRE_LEGAL_INFO_HOOKS       ?=
$(2)_POST_LEGAL_INFO_HOOKS      ?=

# human-friendly targets and target sequencing
$(1):			$(1)-install

ifeq ($$($(2)_TYPE),host)
$(1)-install:	        $(1)-install-host
else
$(1)-install:		$(1)-install-staging $(1)-install-target $(1)-install-images
endif

ifeq ($$($(2)_INSTALL_TARGET),YES)
$(1)-install-target:		$$($(2)_TARGET_INSTALL_TARGET)
$$($(2)_TARGET_INSTALL_TARGET):	$$($(2)_TARGET_BUILD)
else
$(1)-install-target:
endif

ifeq ($$($(2)_INSTALL_STAGING),YES)
$(1)-install-staging:			$$($(2)_TARGET_INSTALL_STAGING)
$$($(2)_TARGET_INSTALL_STAGING):	$$($(2)_TARGET_BUILD)
# Some packages use install-staging stuff for install-target
$$($(2)_TARGET_INSTALL_TARGET):		$$($(2)_TARGET_INSTALL_STAGING)
else
$(1)-install-staging:
endif

ifeq ($$($(2)_INSTALL_IMAGES),YES)
$(1)-install-images:		$$($(2)_TARGET_INSTALL_IMAGES)
$$($(2)_TARGET_INSTALL_IMAGES):	$$($(2)_TARGET_BUILD)
else
$(1)-install-images:
endif

$(1)-install-host:      	$$($(2)_TARGET_INSTALL_HOST)
$$($(2)_TARGET_INSTALL_HOST):	$$($(2)_TARGET_BUILD)

$(1)-build:		$$($(2)_TARGET_BUILD)
$$($(2)_TARGET_BUILD):	$$($(2)_TARGET_CONFIGURE)

# Since $(2)_FINAL_DEPENDENCIES are phony targets, they are always "newer"
# than $(2)_TARGET_CONFIGURE. This would force the configure step (and
# therefore the other steps as well) to be re-executed with every
# invocation of make.  Therefore, make $(2)_FINAL_DEPENDENCIES an order-only
# dependency by using |.

$(1)-configure:			$$($(2)_TARGET_CONFIGURE)
$$($(2)_TARGET_CONFIGURE):	| $$($(2)_FINAL_DEPENDENCIES)

$$($(2)_TARGET_SOURCE) $$($(2)_TARGET_RSYNC): | dirs prepare
ifeq ($$(filter $(1),$$(DEPENDENCIES_HOST_PREREQ)),)
$$($(2)_TARGET_SOURCE) $$($(2)_TARGET_RSYNC): | dependencies
endif

ifeq ($$($(2)_OVERRIDE_SRCDIR),)
# In the normal case (no package override), the sequence of steps is
#  source, by downloading
#  depends
#  extract
#  patch
#  configure
$$($(2)_TARGET_CONFIGURE):	$$($(2)_TARGET_PATCH)

$(1)-patch:		$$($(2)_TARGET_PATCH)
$$($(2)_TARGET_PATCH):	$$($(2)_TARGET_EXTRACT)

$(1)-extract:			$$($(2)_TARGET_EXTRACT)
$$($(2)_TARGET_EXTRACT):	$$($(2)_TARGET_SOURCE)

$(1)-depends:		$$($(2)_FINAL_DEPENDENCIES)

$(1)-source:		$$($(2)_TARGET_SOURCE)
else
# In the package override case, the sequence of steps
#  source, by rsyncing
#  depends
#  configure

# Use an order-only dependency so the "<pkg>-clean-for-rebuild" rule
# can remove the stamp file without triggering the configure step.
$$($(2)_TARGET_CONFIGURE): | $$($(2)_TARGET_RSYNC)

$(1)-depends:		$$($(2)_FINAL_DEPENDENCIES)

$(1)-patch:		$(1)-rsync
$(1)-extract:		$(1)-rsync

$(1)-rsync:		$$($(2)_TARGET_RSYNC)

$(1)-source:		$$($(2)_TARGET_RSYNC_SOURCE)
endif

$(1)-show-depends:
			@echo $$($(2)_FINAL_DEPENDENCIES)

$(1)-graph-depends: graph-depends-requirements
			@$$(INSTALL) -d $$(O)/graphs
			@cd "$$(CONFIG_DIR)"; \
			$$(TOPDIR)/support/scripts/graph-depends -p $(1) $$(BR2_GRAPH_DEPS_OPTS) \
			|tee $$(O)/graphs/$$(@).dot \
			|dot $$(BR2_GRAPH_DOT_OPTS) -T$$(BR_GRAPH_OUT) -o $$(O)/graphs/$$(@).$$(BR_GRAPH_OUT)

$(1)-dirclean:		$$($(2)_TARGET_DIRCLEAN)

$(1)-clean-for-reinstall:
ifneq ($$($(2)_OVERRIDE_SRCDIR),)
			rm -f $$($(2)_TARGET_RSYNC)
endif
			rm -f $$($(2)_TARGET_INSTALL_STAGING)
			rm -f $$($(2)_TARGET_INSTALL_TARGET)
			rm -f $$($(2)_TARGET_INSTALL_IMAGES)
			rm -f $$($(2)_TARGET_INSTALL_HOST)

$(1)-reinstall:		$(1)-clean-for-reinstall $(1)

$(1)-clean-for-rebuild: $(1)-clean-for-reinstall
			rm -f $$($(2)_TARGET_BUILD)

$(1)-rebuild:		$(1)-clean-for-rebuild $(1)

$(1)-clean-for-reconfigure: $(1)-clean-for-rebuild
			rm -f $$($(2)_TARGET_CONFIGURE)

$(1)-reconfigure:	$(1)-clean-for-reconfigure $(1)

# define the PKG variable for all targets, containing the
# uppercase package variable prefix
$$($(2)_TARGET_INSTALL_TARGET):		PKG=$(2)
$$($(2)_TARGET_INSTALL_STAGING):	PKG=$(2)
$$($(2)_TARGET_INSTALL_IMAGES):		PKG=$(2)
$$($(2)_TARGET_INSTALL_HOST):           PKG=$(2)
$$($(2)_TARGET_BUILD):			PKG=$(2)
$$($(2)_TARGET_CONFIGURE):		PKG=$(2)
$$($(2)_TARGET_RSYNC):                  SRCDIR=$$($(2)_OVERRIDE_SRCDIR)
$$($(2)_TARGET_RSYNC):                  PKG=$(2)
$$($(2)_TARGET_RSYNC_SOURCE):		SRCDIR=$$($(2)_OVERRIDE_SRCDIR)
$$($(2)_TARGET_RSYNC_SOURCE):		PKG=$(2)
$$($(2)_TARGET_PATCH):			PKG=$(2)
$$($(2)_TARGET_PATCH):			RAWNAME=$$(patsubst host-%,%,$(1))
$$($(2)_TARGET_PATCH):			PKGDIR=$(pkgdir)
$$($(2)_TARGET_EXTRACT):		PKG=$(2)
$$($(2)_TARGET_SOURCE):			PKG=$(2)
$$($(2)_TARGET_SOURCE):			PKGDIR=$(pkgdir)
$$($(2)_TARGET_DIRCLEAN):		PKG=$(2)

# Compute the name of the Kconfig option that correspond to the
# package being enabled. We handle three cases: the special Linux
# kernel case, the bootloaders case, and the normal packages case.
ifeq ($(1),linux)
$(2)_KCONFIG_VAR = BR2_LINUX_KERNEL
else ifneq ($$(filter boot/%,$(pkgdir)),)
$(2)_KCONFIG_VAR = BR2_TARGET_$(2)
else ifneq ($$(filter toolchain/%,$(pkgdir)),)
$(2)_KCONFIG_VAR = BR2_$(2)
else
$(2)_KCONFIG_VAR = BR2_PACKAGE_$(2)
endif

# legal-info: declare dependencies and set values used later for the manifest
ifneq ($$($(2)_LICENSE_FILES),)
$(2)_MANIFEST_LICENSE_FILES = $$($(2)_LICENSE_FILES)
endif
$(2)_MANIFEST_LICENSE_FILES ?= not saved

# If the package declares _LICENSE_FILES, we need to extract it,
# for overriden, local or normal remote packages alike, whether
# we want to redistribute it or not.
ifneq ($$($(2)_LICENSE_FILES),)
$(1)-legal-info: $(1)-patch
endif

# We only save the sources of packages we want to redistribute, that are
# non-local, and non-overriden. So only store, in the manifest, the tarball
# name of those packages.
ifeq ($$($(2)_REDISTRIBUTE),YES)
ifneq ($$($(2)_SITE_METHOD),local)
ifneq ($$($(2)_SITE_METHOD),override)
# Packages that have a tarball need it downloaded beforehand
$(1)-legal-info: $(1)-source $$(REDIST_SOURCES_DIR_$$(call UPPERCASE,$(4)))
$(2)_MANIFEST_TARBALL = $$($(2)_SOURCE)
$(2)_MANIFEST_SITE = $$(call qstrip,$$($(2)_SITE))
endif
endif
endif

# legal-info: produce legally relevant info.
$(1)-legal-info:
# Packages without a source are assumed to be part of Buildroot, skip them.
	$$(foreach hook,$$($(2)_PRE_LEGAL_INFO_HOOKS),$$(call $$(hook))$$(sep))
ifneq ($$(call qstrip,$$($(2)_SOURCE)),)

# Save license files if defined
# We save the license files for any kind of package: normal, local,
# overridden, or non-redistributable alike.
# The reason to save license files even for no-redistribute packages
# is that the license still applies to the files distributed as part
# of the rootfs, even if the sources are not themselves redistributed.
ifeq ($$(call qstrip,$$($(2)_LICENSE_FILES)),)
	@$$(call legal-license-nofiles,$$($(2)_RAWNAME),$$(call UPPERCASE,$(4)))
	@$$(call legal-warning-pkg,$$($(2)_RAWNAME),cannot save license ($(2)_LICENSE_FILES not defined))
else
	@$$(foreach F,$$($(2)_LICENSE_FILES),$$(call legal-license-file,$$($(2)_RAWNAME),$$(F),$$($(2)_DIR)/$$(F),$$(call UPPERCASE,$(4)))$$(sep))
endif # license files

ifeq ($$($(2)_SITE_METHOD),local)
# Packages without a tarball: don't save and warn
	@$$(call legal-warning-nosource,$$($(2)_RAWNAME),local)

else ifneq ($$($(2)_OVERRIDE_SRCDIR),)
	@$$(call legal-warning-nosource,$$($(2)_RAWNAME),override)

else
# Other packages

ifeq ($$($(2)_REDISTRIBUTE),YES)
# Copy the source tarball (just hardlink if possible)
	@cp -l $$(DL_DIR)/$$($(2)_SOURCE) $$(REDIST_SOURCES_DIR_$$(call UPPERCASE,$(4))) 2>/dev/null || \
	   cp $$(DL_DIR)/$$($(2)_SOURCE) $$(REDIST_SOURCES_DIR_$$(call UPPERCASE,$(4)))
endif # redistribute

endif # other packages
	@$$(call legal-manifest,$$($(2)_RAWNAME),$$($(2)_VERSION),$$($(2)_LICENSE),$$($(2)_MANIFEST_LICENSE_FILES),$$($(2)_MANIFEST_TARBALL),$$($(2)_MANIFEST_SITE),$$(call UPPERCASE,$(4)))
endif # ifneq ($$(call qstrip,$$($(2)_SOURCE)),)
	$$(foreach hook,$$($(2)_POST_LEGAL_INFO_HOOKS),$$(call $$(hook))$$(sep))

# add package to the general list of targets if requested by the buildroot
# configuration
ifeq ($$($$($(2)_KCONFIG_VAR)),y)

# Ensure the calling package is the declared provider for all the virtual
# packages it claims to be an implementation of.
ifneq ($$($(2)_PROVIDES),)
$$(foreach pkg,$$($(2)_PROVIDES),\
	$$(eval $$(call virt-provides-single,$$(pkg),$$(call UPPERCASE,$$(pkg)),$(1))$$(sep)))
endif

# Ensure unified variable name conventions between all packages Some
# of the variables are used by more than one infrastructure; so,
# rather than duplicating the checks in each infrastructure, we check
# all variables here in pkg-generic, even though pkg-generic should
# have no knowledge of infra-specific variables.
$(eval $(call check-deprecated-variable,$(2)_MAKE_OPT,$(2)_MAKE_OPTS))
$(eval $(call check-deprecated-variable,$(2)_INSTALL_OPT,$(2)_INSTALL_OPTS))
$(eval $(call check-deprecated-variable,$(2)_INSTALL_TARGET_OPT,$(2)_INSTALL_TARGET_OPTS))
$(eval $(call check-deprecated-variable,$(2)_INSTALL_STAGING_OPT,$(2)_INSTALL_STAGING_OPTS))
$(eval $(call check-deprecated-variable,$(2)_INSTALL_HOST_OPT,$(2)_INSTALL_HOST_OPTS))
$(eval $(call check-deprecated-variable,$(2)_AUTORECONF_OPT,$(2)_AUTORECONF_OPTS))
$(eval $(call check-deprecated-variable,$(2)_CONF_OPT,$(2)_CONF_OPTS))
$(eval $(call check-deprecated-variable,$(2)_BUILD_OPT,$(2)_BUILD_OPTS))
$(eval $(call check-deprecated-variable,$(2)_GETTEXTIZE_OPT,$(2)_GETTEXTIZE_OPTS))
$(eval $(call check-deprecated-variable,$(2)_KCONFIG_OPT,$(2)_KCONFIG_OPTS))

BUNDLES += $(1)

ifneq ($$($(2)_PERMISSIONS),)
PACKAGES_PERMISSIONS_TABLE += $$($(2)_PERMISSIONS)$$(sep)
endif
ifneq ($$($(2)_DEVICES),)
PACKAGES_DEVICES_TABLE += $$($(2)_DEVICES)$$(sep)
endif
ifneq ($$($(2)_USERS),)
PACKAGES_USERS += $$($(2)_USERS)$$(sep)
endif

ifeq ($$($(2)_SITE_METHOD),svn)
DL_TOOLS_DEPENDENCIES += svn
else ifeq ($$($(2)_SITE_METHOD),git)
DL_TOOLS_DEPENDENCIES += git
else ifeq ($$($(2)_SITE_METHOD),bzr)
DL_TOOLS_DEPENDENCIES += bzr
else ifeq ($$($(2)_SITE_METHOD),scp)
DL_TOOLS_DEPENDENCIES += scp ssh
else ifeq ($$($(2)_SITE_METHOD),hg)
DL_TOOLS_DEPENDENCIES += hg
else ifeq ($$($(2)_SITE_METHOD),cvs)
DL_TOOLS_DEPENDENCIES += cvs
endif # SITE_METHOD

# $(firstword) is used here because the extractor can have arguments, like
# ZCAT="gzip -d -c", and to check for the dependency we only want 'gzip'.
# Do not add xzcat to the list of required dependencies, as it gets built
# automatically if it isn't found.
ifneq ($$(call suitable-extractor,$$($(2)_SOURCE)),$$(XZCAT))
DL_TOOLS_DEPENDENCIES += $$(firstword $$(call suitable-extractor,$$($(2)_SOURCE)))
endif

endif # $(2)_KCONFIG_VAR
endef # inner-generic-bundle-package

################################################################################
# generic-bundle-package -- the target generator macro for generic packages
################################################################################

# In the case of target packages, keep the package name "pkg"
generic-bundle-package = $(call inner-generic-bundle-package,$(pkgname),$(call UPPERCASE,$(pkgname)),$(call UPPERCASE,$(pkgname)),target)
# In the case of host packages, turn the package name "pkg" into "host-pkg"
host-generic-bundle-package = $(call inner-generic-bundle-package,host-$(pkgname),$(call UPPERCASE,host-$(pkgname)),$(call UPPERCASE,$(pkgname)),host)

# :mode=makefile:

################################################################################
# Virtual package infrastructure
#
# This file implements an infrastructure that eases development of
# package .mk files for virtual packages. It should be used for all
# virtual packages.
#
# See the Buildroot documentation for details on the usage of this
# infrastructure
#
# In terms of implementation, this virtual infrastructure requires
# the .mk file to only call the 'virtual-package' macro.
#
################################################################################

define bundle-install-package
	$$($(1)_FAKEROOT) $(TAR) --overwrite -C $(3) -xf $$($(2)_TARGET_ARCHIVE);
	@echo "Importing $(2)";
endef

ifeq ($(BR2_BR2_ROOTFS_REMOVE_DOCUMENTATION),y)
define bundle-remove-documentation
	rm -rf $(1)/usr/share/{doc,man,info,gtk-doc,aclocal}/*
endef
endif

ifeq ($(BR2_ROOTFS_REMOVE_DEVELOPMENT),y)
define bundle-remove-development
	rm -rf $(1)/usr/lib/cmake
    rm -rf $(1)/usr/include/*
    rm -rf $(1)/usr/lib/pkgconfig/*
	rm -f $(1)/usr/lib/*.{a,la,sh,py}
    rm -f $(1)/lib/*.{a,la,sh,py}
    rm -f $(1)/usr/bin/*-config
    rm -f $(1)/usr/bin/*_config
endef
endif

ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_LZ4),y)
BUNDLE_SQUASHFS_ARGS += -comp lz4
else
ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_LZO),y)
BUNDLE_SQUASHFS_ARGS += -comp lzo
else
ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_LZMA),y)
BUNDLE_SQUASHFS_ARGS += -comp lzma
else
ifeq ($(BR2_TARGET_ROOTFS_COLIBRI_XZ),y)
BUNDLE_SQUASHFS_ARGS += -comp xz
else
BUNDLE_SQUASHFS_ARGS += -comp gzip
endif
endif
endif
endif

BUNDLE_SQUASHFS_ARGS += -b 512K -no-xattrs -noappend

################################################################################
# inner-bundle-package -- defines the dependency rules of the virtual
# package against its provider.
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name, including a HOST_ prefix
#             for host packages
#  argument 3 is the uppercase package name, without the HOST_ prefix
#             for host packages
#  argument 4 is the type (target or host)
################################################################################

# Note: putting this comment here rather than in the define block, otherwise
# make would try to expand the $(error ...) in the comment, which is not
# really what we want.
# We need to use second-expansion for the $(error ...) call, below,
# so it is not evaluated now, but as part of the generated make code.

MKSQUASHFS := $(HOST_DIR)/usr/bin/mksquashfs

define inner-bundle-package

ifndef $(2)_MKSQUASHFS
 ifdef $(3)_MKSQUASHFS
  $(2)_MKSQUASHFS = $$($(3)_MKSQUASHFS)
 else
  $(2)_MKSQUASHFS ?= $$(MKSQUASHFS)
 endif
endif

ifndef $(2)_MD5SUM
 ifdef $(3)_MD5SUM
	$(2)_MD5SUM = $$($(3)_MD5SUM)
 else
	$(2)_MD5SUM ?= md5sum
 endif
endif

# Ensure the virtual package has an implementation defined.
#~ ifeq ($$(BR2_PACKAGE_HAS_$(2)),y)
#~ ifeq ($$(call qstrip,$$(BR2_PACKAGE_PROVIDES_$(2))),)
#~ $$(error No implementation selected for virtual package $(1). Configuration error)
#~ endif
#~ endif

$(2)_ADD_TOOLCHAIN_DEPENDENCY = NO

$(2)_ARCHIVE_TARGET = NO

# A virtual package does not have any source associated
$(2)_SOURCE =

$(2)_BUNDLE_IMAGE = $$($(2)_ORDER)-$(1)-$$($(2)_VERSION).cb
$(2)_BUNDLE_IMAGE_HASH = $$($(2)_BUNDLE_IMAGE).md5sum

# Fake a version string, so it looks nicer in the build log
#$(2)_VERSION = virtual

# This must be repeated from inner-generic-package, otherwise we get an empty
# _DEPENDENCIES
#ifeq ($(4),host)
#$(2)_DEPENDENCIES ?= $$(filter-out host-toolchain $(1),\
#	$$(patsubst host-host-%,host-%,$$(addprefix host-,$$($(3)_DEPENDENCIES))))
#endif

# Add dependency against the provider
$(2)_DEPENDENCIES += $$(call qstrip,$$($(2)_PACKAGES)) host-squashfs

#~ ifeq ($(2)_ADD_ROOTFS,YES)
#~ 	$(2)_DEPENDENCIES += rootfs-tar
#~ endif

#
# Target installation step. Only define it if not already defined by
# the package .mk file.
#



ifndef $(2)_INSTALL_TARGET_CMDS
define $(2)_INSTALL_TARGET_CMDS
	mkdir -p $$($(2)_TARGET_DIR)
	if [ "x$($(2)_ADD_ROOTFS)" == "xYES" ] ; then \
		$$($(2)_FAKEROOT) $(TAR) --overwrite -C $$($(2)_TARGET_DIR) -xf $(BINARIES_DIR)/rootfs.tar; \
	fi
	$(foreach pkgname,$($(2)_PACKAGES),$(call bundle-install-package,$(2),$(call UPPERCASE,$(pkgname)), $$($(2)_TARGET_DIR)))
	
	$(call bundle-remove-documentation,$$($(2)_TARGET_DIR))
	$(call bundle-remove-development,$$($(2)_TARGET_DIR))
	
	$$($(2)_FAKEROOT) $$($(2)_MKSQUASHFS) $$($(2)_TARGET_DIR) $(BUNDLES_DIR)/$$($(2)_BUNDLE_IMAGE) $(BUNDLE_SQUASHFS_ARGS) 
	$$($(2)_MD5SUM) $(BUNDLES_DIR)/$$($(2)_BUNDLE_IMAGE) > $(BUNDLES_DIR)/$$($(2)_BUNDLE_IMAGE_HASH)
	rm -rf $$($(2)_TARGET_DIR)
endef
endif

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-bundle-package,$(1),$(2),$(3),$(4))

endef

################################################################################
# bundle-package -- the target generator macro for bundle packages
################################################################################

bundle-package = $(call inner-bundle-package,$(pkgname),$(call UPPERCASE,$(pkgname)),$(call UPPERCASE,$(pkgname)),target)
