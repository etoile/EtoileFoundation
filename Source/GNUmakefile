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
	NSObject+Mixins.m \
	NSObject+Prototypes.m \
	NSFileManager+TempFile.m\
	NSFileHandle+Socket.m\
	UKPluginsRegistry.m \
	ETCollection.m \
	ETCollection+HOM.m \
	ETFilter.m \
	ETGetOptionsDictionary.m \
	ETHistory.m \
	ETModelDescription.m \
	ETObjectChain.m \
	ETPropertyValueCoding.m \
	ETSocket.m\
	ETTranscript.m \
	ETTransform.m \
	ETUUID.m \
	ETUTI.m \
	NSIndexPath+Etoile.m \
	NSIndexSet+Etoile.m \
	NSInvocation+Etoile.m \
	NSObject+Etoile.m \
	NSObject+HOM.m \
	NSObject+Model.m \
	NSString+Etoile.m \
	NSURL+Etoile.m \
	ETReflection.m

libEtoileFoundation_C_FILES = \
	ETCArray.c

ifeq ($(GNUSTEP_TARGET_CPU), ix86)
  ADDITIONAL_OBJCFLAGS += -march=i586
endif


ifeq ($(build_deprecated), yes)
libEtoileFoundation_OBJC_FILES += NSFileManager+NameForTempFile.m
endif

ifeq ($(test), yes)
libEtoileFoundation_OBJC_FILES += TestBasicHOM.m TestETCollectionHOM.m TestUUID.m TestUTI.m TestReflection.m
endif

include $(GNUSTEP_MAKEFILES)/subproject.make
