################################################################################
#
# micromamba
#
################################################################################

MICROMAMBA_VERSION = 1.0.0
MICROMAMBA_SITE = $(call github,mamba-org,mamba,micromamba-$(MICROMAMBA_VERSION))
MICROMAMBA_LICENSE = BSD-3-Clause
MICROMAMBA_LICENSE_FILES = LICENSE
MICROMAMBA_DEPENDENCIES = \
	$(BR2_PYTHON3_HOST_DEPENDENCY) \
	cli11 \
	fmt \
	json-for-modern-cpp \
	libarchive \
	libcurl \
	libsolv \
	openssl \
	reproc \
	spdlog \
	termcolor \
	tl-expected \
	yaml-cpp

MICROMAMBA_CONF_OPTS = -DBUILD_LIBMAMBA=ON -DBUILD_MICROMAMBA=ON

# See libmamba/include/mamba/core/context.hpp
ifeq ($(BR2_ARM_CPU_ARMV6),y)
MICROMAMBA_CONF_OPTS += -DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -D___ARM_ARCH_6__"
else ifeq ($(BR2_ARM_CPU_ARMV7A),y)
MICROMAMBA_CONF_OPTS += -DCMAKE_CXX_FLAGS="$(TARGET_CXXFLAGS) -D__ARM_ARCH_7__"
endif

ifeq ($(BR2_STATIC_LIBS),y)
MICROMAMBA_CONF_OPTS += -DBUILD_STATIC=ON -DMICROMAMBA_LINKAGE=FULL_STATIC
else ifeq ($(BR2_SHARED_STATIC_LIBS),y)
MICROMAMBA_CONF_OPTS += -DBUILD_SHARED=ON -DBUILD_STATIC=ON
else # BR2_SHARED_LIBS
MICROMAMBA_CONF_OPTS += -DBUILD_SHARED=ON
endif

$(eval $(cmake-package))
