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
LIBRARY_NAME = libEtoileFoundation
VERSION = 0.1

# For FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm

#
# Resource files
#
$(LIBRARY_NAME)_MAIN_MODEL_FILE =

$(LIBRARY_NAME)_RESOURCE_FILES =

$(LIBRARY_NAME)_LOCALIZED_RESOURCE_FILES =

#
# Languages we're localized for
#
$(LIBRARY_NAME)_LANGUAGES = \
	English
	
#
# Class files
#
$(LIBRARY_NAME)_OBJC_FILES = \
	NSFileManager+NameForTempFile.m \
	UKMainThreadProxy.m \
	UKNibOwner.m \
	UKPluginsRegistry.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m
	
ifeq ($(kqueue_supported), yes)

$(LIBRARY_NAME)_OBJC_FILES += \
	UKKQueue.m

endif

#
# Header files to be installed
#
$(LIBRARY_NAME)_HEADER_FILES_DIR = ../Headers

$(LIBRARY_NAME)_HEADER_FILES_INSTALL_DIR = /EtoileFoundation

$(LIBRARY_NAME)_HEADER_FILES = \
	Cocoa.h \
	EtoileCompatibility.h \
	NSFileManager+NameForTempFile.h \
	UKMainThreadProxy.h \
	UKNibOwner.h \
	UKPluginsRegistry.h \
	UKPushbackMessenger.h \
	UKThreadMessenger.h
	
ifeq ($(kqueue_supported), yes)

$(LIBRARY_NAME)_HEADER_FILES += \
	UKKQueue.h \
	UKFileWatcher.h

endif

#
# C files
#
$(LIBRARY_NAME)_C_FILES =

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble
