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

VERSION = 0.4.1

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
	NSObject+Mixins.h \
	NSFileManager+TempFile.h \
	UKPluginsRegistry.h \
	ETCollection.h \
	ETCollection+HOM.h \
	ETFilter.h \
	ETHistory.h \
	ETModelDescription.h \
	ETObjectChain.h \
	ETPropertyValueCoding.h \
	ETRendering.h \
	ETTranscript.h \
	ETTransform.h \
	ETUUID.h \
	NSIndexPath+Etoile.h \
	NSIndexSet+Etoile.h \
	NSInvocation+Etoile.h \
	NSObject+Etoile.h \
	NSObject+HOM.h \
	NSObject+Model.h \
	NSObject+Prototypes.h \
	NSString+Etoile.h \
	NSURL+Etoile.h \
	ETUTI.h \
	ETReflection.h

EtoileFoundation_RESOURCE_FILES = \
	UTIDefinitions.plist \
	UTIClassBindings.plist

ifeq ($(build_deprecated), yes)
EtoileFoundation_HEADER_FILES += NSFileManager+NameForTempFile.h
endif

ifeq ($(GNUSTEP_TARGET_CPU), ix86)
 ADDITIONAL_OBJCFLAGS += -march=i586
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make
-include ../../etoile.make
-include etoile.make
ifeq ($(test), yes)
include $(GNUSTEP_MAKEFILES)/bundle.make
else
include $(GNUSTEP_MAKEFILES)/framework.make
endif
