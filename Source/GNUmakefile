include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libEtoileFoundation

# For FreeBSD at least
LIBRARIES_DEPEND_UPON += -lm

#
# Class files
#
libEtoileFoundation_OBJC_FILES = \
	NSFileManager+NameForTempFile.m \
	UKMainThreadProxy.m \
	UKPluginsRegistry.m \
	UKPushbackMessenger.m \
	UKThreadMessenger.m \
	OSBundleExtensionLoader.m
	
ifeq ($(kqueue_supported), yes)

libEtoileFoundation_OBJC_FILES += \
	UKKQueue.m

endif

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/subproject.make
-include GNUmakefile.postamble

