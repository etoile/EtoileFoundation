include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libEtoileFoundation

# At a future point, we could use libosspuuid (see ../GNUmakefile):
#libEtoileFoundation_INCLUDE_DIRS += $(shell uuid-config --cflags)
libEtoileFoundation_CPPFLAGS += -D_POSIX_C_SOURCE=2
libEtoileFoundation_OBJCFLAGS += -std=c99 
libEtoileFoundation_CFLAGS += -std=c99

#
# Class files
#
libEtoileFoundation_OBJC_FILES = \
	NSArray+map.m \
	NSObject+Mixins.m \
	NSFileManager+TempFile.m\
	UKMainThreadProxy.m \
	UKPluginsRegistry.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m \
	OSBundleExtensionLoader.m \
	ETCollection.m \
	ETFilter.m \
	ETGetOptionsDictionary.m \
	ETObjectChain.m \
	ETObjectRegistry.m \
	ETPropertyValueCoding.m \
	ETPrototype.m \
	ETTransform.m \
	ETUUID.m \
	NSIndexPath+Etoile.m \
	NSIndexSet+Etoile.m \
	NSInvocation+Etoile.m \
	NSObject+Etoile.m \
	NSObject+Model.m \
	NSString+Etoile.m \
	NSURL+Etoile.m

libEtoileFoundation_C_FILES = \
	ETCArray.c

ifeq ($(build_deprecated), yes)
libEtoileFoundation_OBJC_FILES += NSFileManager+NameForTempFile.m
endif

ifeq ($(kqueue_supported), yes)
libEtoileFoundation_OBJC_FILES += UKKQueue.m
endif

ifeq ($(test), yes)
libEtoileFoundation_OBJC_FILES += TestUUID.m
endif

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/subproject.make
-include GNUmakefile.postamble
