include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libEtoileFoundation

# At a future point, we could use libosspuuid (see ../GNUmakefile):
#libEtoileFoundation_INCLUDE_DIRS += $(shell uuid-config --cflags)
libEtoileFoundation_CPPFLAGS += -D_GNU_SOURCE -DUKTEST_LONG

libEtoileFoundation_OBJCFLAGS += -std=c99 
libEtoileFoundation_CFLAGS += -std=c99

#
# Class files
#
libEtoileFoundation_OBJC_FILES = \
	NSArray+map.m \
	NSObject+Mixins.m \
	NSObject+Prototypes.m \
	NSFileManager+TempFile.m\
	UKMainThreadProxy.m \
	UKPluginsRegistry.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m \
	OSBundleExtensionLoader.m \
	ETCollection.m \
	ETFilter.m \
	ETGetOptionsDictionary.m \
	ETHistoryManager.m \
	ETModelDescription.m \
	ETObjectChain.m \
	ETObjectRegistry.m \
	ETPropertyValueCoding.m \
	ETTranscript.m \
	ETTransform.m \
	ETUUID.m \
	ETUTI.m \
	NSIndexPath+Etoile.m \
	NSIndexSet+Etoile.m \
	NSInvocation+Etoile.m \
	NSObject+Etoile.m \
	NSObject+Model.m \
	NSString+Etoile.m \
	NSURL+Etoile.m

libEtoileFoundation_C_FILES = \
	ETCArray.c

ifeq ($(GNUSTEP_TARGET_CPU), ix86)
  ADDITIONAL_OBJCFLAGS += -march=i586
endif


ifeq ($(build_deprecated), yes)
libEtoileFoundation_OBJC_FILES += NSFileManager+NameForTempFile.m
endif

ifeq ($(test), yes)
libEtoileFoundation_OBJC_FILES += TestUUID.m TestUTI.m
endif

include $(GNUSTEP_MAKEFILES)/subproject.make
