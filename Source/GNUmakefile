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
LIBRARY_NAME = libEtoileExtensions	
VERSION = 0.1

FRAMEWORKS = #TrackerKit

# For FreeBSD at least
LIBRARIES_DEPEND_UPON = -lm

#
# Resource files
#
libEtoileExtensions_MAIN_MODEL_FILE =

libEtoileExtensions_RESOURCE_FILES =

libEtoileExtensions_LOCALIZED_RESOURCE_FILES =

#
# Languages we're localized for
#
libEtoileExtensions_LANGUAGES = \
	English
	
#
# Class files
#
libEtoileExtensions_OBJC_FILES = \
	NSBezierPathCappedBoxes.m \
	NSFileManager+NameForTempFile.m \
	NSImage+NiceScaling.m \
	UKDistributedView.m \
	UKFinderIconCell.m \
	UKMainThreadProxy.m \
	UKNibOwner.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m
	
ifeq ($(kqueue_supported), yes)

libEtoileExtensions_OBJC_FILES += \
	UKKQueue.m \
	UKMainThreadProxy.m 

endif

#
# Header files
#
libEtoileExtensions_HEADER_FILES_DIR = ../Headers

libEtoileExtensions_HEADER_FILES_INSTALL_DIR = /EtoileExtensions

libEtoileExtensions_HEADER_FILES = \
	Cocoa/Cocoa.h \
	EtoileCompatibility.h \
	NSBezierPathCappedBoxes.h \
	NSFileManager+NameForTempFile.h \
	NSImage+NiceScaling.h \
	UKDistributedView.h \
	UKFinderIconCell.h \
	UKMainThreadProxy.h \
	UKNibOwner.h \
	UKPushbackMessenger.h \
	UKThreadMessenger.h
	
ifeq ($(kqueue_supported), yes)

libEtoileExtensions_HEADER_FILES += \
	UKKQueue.h \
	UKFileWatcher.h

endif

#
# C files
#
libEtoileExtensions_C_FILES =

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/library.make

-include GNUmakefile.postamble
