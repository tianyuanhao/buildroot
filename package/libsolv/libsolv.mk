################################################################################
#
# libsolv
#
################################################################################

LIBSOLV_VERSION = 0.7.22
LIBSOLV_SITE = $(call github,openSUSE,libsolv,$(LIBSOLV_VERSION))
LIBSOLV_LICENSE = BSD-3-Clause
LIBSOLV_LICENSE_FILES = LICENSE.BSD
LIBSOLV_INSTALL_STAGING = YES
LIBSOLV_DEPENDENCIES = zlib
LIBSOLV_CONF_OPTS = -DCMAKE_CXX_COMPILER_FORCED=ON

ifeq ($(BR2_STATIC_LIBS),y)
LIBSOLV_CONF_OPTS += -DDISABLE_SHARED=ON
else ifeq ($(BR2_SHARED_STATIC_LIBS),y)
LIBSOLV_CONF_OPTS += -DENABLE_STATIC=ON
endif

ifeq ($(BR2_PACKAGE_MICROMAMBA),y)
LIBSOLV_CONF_OPTS += -DENABLE_CONDA=ON
endif

$(eval $(cmake-package))
