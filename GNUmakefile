PACKAGE_NAME = EtoileFoundation

include $(GNUSTEP_MAKEFILES)/common.make

ifneq ($(test), yes)
SUBPROJECTS = EtoileThread EtoileXML
endif

ifneq ($(findstring freebsd, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
    libuuid_embedded ?= yes
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

ifeq ($(test), yes)
BUNDLE_NAME = EtoileFoundation
else
FRAMEWORK_NAME = EtoileFoundation
endif

VERSION = 0.1

# -lm for FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm -lEtoileThread -lEtoileXML \
	$(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

ifeq ($(test), yes)
EtoileFoundation_LDFLAGS += -lUnitKit
endif

EtoileFoundation_SUBPROJECTS += Source

# We import external headers like uuid_dce.h by collecting all headers in a 
# common directory 'EtoileFoundation' with before-all:: (see GNUmakefile.postamble)
EtoileFoundation_HEADER_FILES_DIR = ./EtoileFoundation

EtoileFoundation_HEADER_FILES = \
	EtoileFoundation.h \
	ETGetOptionsDictionary.h \
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

ifeq ($(custom_libobjc), yes)
libEtoileFoundation_HEADER_FILES += ETPrototype.h
endif

ifeq ($(build_deprecated), yes)
EtoileFoundation_HEADER_FILES += NSFileManager+NameForTempFile.h
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include ../../etoile.make
-include etoile.make
-include GNUmakefile.postamble
ifeq ($(test), yes)
include $(GNUSTEP_MAKEFILES)/bundle.make
else
include $(GNUSTEP_MAKEFILES)/framework.make
endif
