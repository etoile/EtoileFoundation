include $(GNUSTEP_MAKEFILES)/common.make

#
# kqueue support check
#
ifneq ($(findstring freebsd, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

ifneq ($(findstring netbsd, $(GNUSTEP_HOST_OS)),)

    kqueue_supported ?= yes

endif

kqueue_supported ?= no


ADDITIONAL_OBJCFLAGS = -Wno-import

ADDITIONAL_INCLUDE_DIRS = -I../Headers

#
# Main application
#
FRAMEWORK_NAME = EtoileFoundation
VERSION = 0.1

# For FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm

#
# Resource files
#
EtoileFoundation_MAIN_MODEL_FILE =

EtoileFoundation_RESOURCE_FILES =

EtoileFoundation_LOCALIZED_RESOURCE_FILES =

#
# Languages we're localized for
#
EtoileFoundation_LANGUAGES = \
	English
	
#
# Class files
#
EtoileFoundation_OBJC_FILES = \
	NSFileManager+NameForTempFile.m \
	UKMainThreadProxy.m \
	UKPluginsRegistry.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m \
	OSBundleExtensionLoader.m
	
ifeq ($(kqueue_supported), yes)

EtoileFoundation_OBJC_FILES += \
	UKKQueue.m

endif

#
# Header files to be installed
#
EtoileFoundation_HEADER_FILES_DIR = ../Headers

EtoileFoundation_HEADER_FILES = \
	EtoileCompatibility.h \
	NSFileManager+NameForTempFile.h \
	UKMainThreadProxy.h \
	UKPluginsRegistry.h \
	UKPushbackMessenger.h \
	UKThreadMessenger.h \
	OSBundleExtensionLoader.h
	
ifeq ($(kqueue_supported), yes)

EtoileFoundation_HEADER_FILES += \
	UKKQueue.h \
	UKFileWatcher.h

endif

#
# C files
#
EtoileFoundation_C_FILES =

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/framework.make
-include GNUmakefile.postamble

