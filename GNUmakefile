PACKAGE_NAME = EtoileFoundation

include $(GNUSTEP_MAKEFILES)/common.make

ifneq ($(test), yes)
SUBPROJECTS = EtoileThread EtoileXML
endif

ifneq ($(findstring freebsd, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
endif

ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
endif

ifneq ($(findstring linux, $(GNUSTEP_HOST_OS)),)
endif

ifneq ($(findstring netbsd, $(GNUSTEP_HOST_OS)),)
    kqueue_supported ?= yes
endif

export kqueue_supported ?= no
export build_deprecated ?= yes

ifeq ($(test), yes)
BUNDLE_NAME = EtoileFoundation
else
FRAMEWORK_NAME = EtoileFoundation
endif

VERSION = 0.4

# -lm for FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm -lEtoileThread -lEtoileXML \
	$(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

ifeq ($(test), yes)
EtoileFoundation_LDFLAGS += -lUnitKit
endif

EtoileFoundation_SUBPROJECTS += Source

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
	ETHistoryManager.h \
	ETObjectChain.h \
	ETObjectRegistry.h \
	ETPropertyValueCoding.h \
	ETPrototype.h \
	ETRendering.h \
	ETTranscript.h \
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

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include ../../etoile.make
-include etoile.make
ifeq ($(test), yes)
include $(GNUSTEP_MAKEFILES)/bundle.make
else
include $(GNUSTEP_MAKEFILES)/framework.make
endif
