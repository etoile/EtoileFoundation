include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libEtoileFoundation

ifeq ($(USE_SSL_PKG), yes)
SSL_CFLAGS = $(shell pkg-config --cflags openssl)
endif

libEtoileFoundation_CPPFLAGS += $(SSL_CFLAGS)
libEtoileFoundation_CPPFLAGS += -D_GNU_SOURCE # For Linux
#libEtoileFoundation_CPPFLAGS += -D_XOPEN_SOURCE=600 # For Solaris
libEtoileFoundation_OBJCFLAGS += -std=c99 
libEtoileFoundation_CFLAGS += -std=c99 $(SSL_CFLAGS)

# Temporary hack to discard -Werror until the tests are cleaned
ifeq ($(test), yes)
	ADDITIONAL_OBJCFLAGS = -Wno-import
endif

#
# Class files
#
libEtoileFoundation_OBJC_FILES = \
	NSObject+Mixins.m \
	NSObject+Prototypes.m \
	NSFileManager+TempFile.m\
	NSFileHandle+Socket.m\
	UKPluginsRegistry.m \
	ETClassMirror.m \
	ETCollection.m \
	ETCollection+HOM.m \
	ETFilter.m \
	ETGetOptionsDictionary.m \
	ETHistory.m \
	ETInstanceVariableMirror.m \
	ETMethodMirror.m \
	ETObjectChain.m \
	ETObjectMirror.m \
	ETPropertyViewpoint.m \
	ETPropertyValueCoding.m \
	ETProtocolMirror.m \
	ETSocket.m\
	ETTranscript.m \
	ETTransform.m \
	ETUUID.m \
	ETUTI.m \
	NSData+Hash.m\
	NSIndexPath+Etoile.m \
	NSIndexSet+Etoile.m \
	NSInvocation+Etoile.m \
	NSObject+Etoile.m \
	NSObject+HOM.m \
	NSObject+Model.m \
	NSString+Etoile.m \
	NSURL+Etoile.m \
	ETReflection.m \
	ETEntityDescription.m \
	ETPropertyDescription.m \
	ETValidationResult.m

ifeq ($(GNU_RUNTIME_VERSION), 2)
libEtoileFoundation_OBJC_FILES += NSBlocks.m
endif

libEtoileFoundation_C_FILES = \
	ETCArray.c

ifeq ($(GNUSTEP_TARGET_CPU), ix86)
  ADDITIONAL_OBJCFLAGS += -march=i586
endif

# Deprecated
libEtoileFoundation_OBJC_FILES += NSFileManager+NameForTempFile.m

ifeq ($(test), yes)
libEtoileFoundation_OBJC_FILES += \
	TestBasicHOM.m \
	TestETCollectionHOM.m \
	TestEntityDescription.m \
	TestReflection.m \
	TestString.m \
	TestUTI.m \
	TestUUID.m
endif

include $(GNUSTEP_MAKEFILES)/subproject.make
