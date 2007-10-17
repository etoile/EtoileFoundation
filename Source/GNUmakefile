include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libEtoileFoundation

# For FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm

#
# Class files
#
libEtoileFoundation_OBJC_FILES = \
	NSArray+map.m\
	NSObject+Mixins.m\
	NSFileManager+NameForTempFile.m \
	UKMainThreadProxy.m \
	UKPluginsRegistry.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m \
	OSBundleExtensionLoader.m

libEtoileFoundation_C_FILES = \
	ETCArray.c
	
ifeq ($(kqueue_supported), yes)

libEtoileFoundation_OBJC_FILES += \
	UKKQueue.m

endif

libEtoileFoundation_OBJCFLAGS += -std=c99

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/subproject.make
-include GNUmakefile.postamble

