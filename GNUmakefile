PACKAGE_NAME = EtoileFoundation

include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = EtoileThread EtoileXML

ifneq ($(findstring freebsd, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
endif

ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
    libuuid_embedded ?= yes
endif

ifneq ($(findstring linux, $(GNUSTEP_HOST_OS)),)
    libuuid_embedded ?= yes
endif

ifneq ($(findstring netbsd, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
endif

export kqueue_supported ?= no
export libuuid_embedded ?= no
export build_deprecated ?= yes

FRAMEWORK_NAME = EtoileFoundation
VERSION = 0.1

ifeq ($(libuuid_embedded), yes)
EtoileFoundation_SUBPROJECTS = UUID
endif

# Linux distributions like Ubuntu doesn't install uuid_dce.h with 
# libosspuuid-dev neither provide a standalone package like libuuid-dce-devel 
# (RPM) on Fedora. When these DCE-compatible header will be widely available we 
# could get rid of our embedded libosspuuid. The following flags returned by 
# uuid-config will have to be used then:
#
# EtoileFoundation_LIBRARY_DIRS += $(shell uuid-config --ldflags)
# LIBRARIES_DEPEND_UPON += $(shell uuid-config --libs)
#
# On plaftorms like FreeBSD, DragonFlyBSD and NetBSD, uuid.h is DCE-compliant 
# and the uuid code is directly part of libc.

# -lm for FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm -lEtoileThread -lEtoileXML \
	$(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

EtoileFoundation_SUBPROJECTS += Source

# We import external headers like uuid_dce.h by collecting all headers in a 
# common directory 'EtoileFoundation' with before-all:: (see GNUmakefile.postamble)
EtoileFoundation_HEADER_FILES_DIR = ./EtoileFoundation

EtoileFoundation_HEADER_FILES = \
	EtoileFoundation.h \
	EtoileCompatibility.h \
	ETCArray.h \
	Macros.h \
	NSArray+map.h \
	NSObject+Mixins.h \
	NSFileManager+TempFile.h \
	UKMainThreadProxy.h \
	UKPluginsRegistry.h \
	UKPushbackMessenger.h \
	UKThreadMessenger.h \
	UKFileWatcher.h \
	OSBundleExtensionLoader.h \
	ETCollection.h \
	ETFilter.h \
	ETObjectChain.h \
	ETObjectRegistry.h \
	ETPropertyValueCoding.h \
	ETPrototype.h \
	ETRendering.h \
	ETTransform.h \
	ETUUID.h \
	NSIndexPath+Etoile.h \
	NSIndexSet+Etoile.h \
	NSInvocation+Etoile.h \
	NSObject+Etoile.h \
	NSObject+Model.h \
	NSString+Etoile.h \
	NSURL+Etoile.h

ifeq ($(build_deprecated), yes)
EtoileFoundation_HEADER_FILES += NSFileManager+NameForTempFile.h
endif

ifeq ($(kqueue_supported), yes)
EtoileFoundation_HEADER_FILES += UKKQueue.h
endif

ifeq ($(libuuid_embedded), yes)
EtoileFoundation_HEADER_FILES += uuid_dce.h
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include ../../etoile.make
-include etoile.make
-include GNUmakefile.postamble
include $(GNUSTEP_MAKEFILES)/framework.make
