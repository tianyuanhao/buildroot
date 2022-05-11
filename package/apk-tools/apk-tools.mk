################################################################################
#
# apk-tools
#
################################################################################

# Regenerate help.h when changing the version number
APK_TOOLS_VERSION = 2.12.9
APK_TOOLS_SITE = https://gitlab.alpinelinux.org/alpine/apk-tools/-/archive/v$(APK_TOOLS_VERSION)
APK_TOOLS_SOURCE = apk-tools-v$(APK_TOOLS_VERSION).tar.bz2
APK_TOOLS_LICENSE = GPL-2.0
APK_TOOLS_LICENSE_FILES = LICENSE

APK_TOOLS_DEPENDENCIES = host-pkgconf openssl zlib

APK_TOOLS_MAKE_OPTS = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	LUA=no \
	SCDOC=: \
	V=1 \
	cmd_genhelp=:

ifeq ($(BR2_SHARED_LIBS),y)
APK_TOOLS_MAKE_OPTS += \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)"
else
APK_TOOLS_MAKE_OPTS += \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY) --static" \
	STATIC=y
endif

define APK_TOOLS_CONFIGURE_CMDS
	$(SED) 's/#\S\+\s\(APK_DEFAULT_ARCH\)\s.*/#define \1 $(BR2_ARCH)/' \
		$(@D)/src/apk_defines.h
	# Copy the pre-generated help.h so we don't need host-lua
	$(INSTALL) -D -m 644 $(APK_TOOLS_PKGDIR)/help.h $(@D)/src/help.h
endef

define APK_TOOLS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) \
		$(APK_TOOLS_MAKE_OPTS)
endef

define APK_TOOLS_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install \
		$(APK_TOOLS_MAKE_OPTS) \
		DESTDIR=$(TARGET_DIR)
	# Prepare an empty apk database
	$(INSTALL) -D -m 644 /dev/null $(TARGET_DIR)/etc/apk/world
	$(INSTALL) -d $(TARGET_DIR)/lib/apk/db
endef

$(eval $(generic-package))
