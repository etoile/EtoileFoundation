UnitKit
=======

Maintainer
: Quentin Mathe <qmathe@club-internet.fr>
Authors
: James Duncan Davidson, Nicolas Roard, Quentin Mathe, David Chisnall, Yen-Ju Chen, Christopher Armstrong, Eric Wasylishen
License
: Apache License 2.0 (see LICENSE document)
Version
: 1.5

UnitKit is a minimalistic unit testing framework that supports Mac OS X, iOS and 
GNUstep. 

The framework is less than 2000 loc, and built around two classes UKRunner and 
UKTestHandler, plus some test macros, and an empty protocol UKTest to mark test 
classes.

The UnitKit core features are:

- Test assertion macros
	- easy to write and read
	- without useless arguments
	- not too many ones
	- extensible (implement a UKTestHandler subclass or category)
- No test case class, just adopt UKTest protocol
- No special methods -setUp and -tearDown, just implement -init and and -dealloc 
- Class test methods in addition to instance ones
- Run loop integration for asynchronous testing
- Uncaught exception reporting
- Delegate methods to signal a test suite will start or just ended
- Tested class choice based on a list or a regex
- Verbose and quiet ouput
- Optional ukrun tool to run test suites packaged in test bundles
- Xcode 3 and higher test suite templates

To know more about UnitKit: <http://www.etoile-project.org/dev/0.4/UnitKit>

**Note:** This UnitKit version is a fork of the original UnitKit written by 
James Duncan Davidson. The original version is not available anymore, and its 
development has been halted for many years. The initial project web site 
unitkit.org is also no longer available.


Build and Install
-----------------

Read INSTALL.Cocoa.md and INSTALL.GNUstep.md documents.


Mac OS X support
----------------

Both Cocoa and Xcode 4 support are actively maintained, and used by several 
Etoile modules that can be built on Mac OS X. However Xcode 3 is not maintained 
anymore.


How to use UnitKit with Mac OS X
--------------------------------

You need to compile your sources as a bundle. If you have installed UnitKit 
as explained in INSTALL.Cocoa.md, with **File -> New -> Target...** Xcode should 
let you create a test bundle target/scheme. In the Xcode Template panel, choose 
**UnitKit Testing Bundle** available in the category **OS X -> Other**.

For running the test suite, click Run in the toolbar. The scheme must 
have the tool set to 'ukrun' in the Run section, and the arguments to:

- -q 
- $TARGET_BUILD_DIR/$WRAPPER_NAME

If you use the template as described above, this is is normally set up 
transparently. However it can be useful to check the scheme is correctly set up 
if the test suite doesn't run.

Inside this bundle, compile the test classes and any additional code needed. 

For testing a framework or library, the test bundle can just link the tested 
product.

**Note:** You can check UnitKitTests target and scheme to understand how to 
create a test bundle manually (without using the UnitKit Testing template).


How to use UnitKit with iOS
---------------------------

You need to compile your sources as an iOS application, since iOS doesn't let 
you run tools or create bundles. 

With **File -> New -> Target...** Xcode should let you create an application 
target/scheme. In the Xcode Template panel, choose **Empty Application** 
available in the category **iOS -> Application**.

For the new target, you should now just keep Info.plist, all the other files 
created by Xcode can be removed (e.g. main.m, AppDelegate.h, AppDelegate.m, 
Prefix.h, localization files and the directory that corresponds to the target on 
disk).

Finally copy UnitKit/Source/iOSCompatibility/main.m in your project, and this 
file to the new target. Based on the UnitKit API, main.m can be customized to 
control the tested classes, the verbosity etc.

For running the test suite, click Run in the toolbar.

Inside this test application, compile the test classes and any additional code 
needed. 

For testing a framework or library, the application can just link the tested 
product.

**Note:** You can check TestUnitKit (iOS) target and scheme to understand how to 
create a iOS test application manually.


How to use UnitKit with GNUstep Make
------------------------------------

You need to compile your sources as a bundle. Here is a GNUmakefile example:

    include $(GNUSTEP_MAKEFILES)/common.make

    BUNDLE_NAME = Test
    Test_OBJC_FILES = # your sources and test classes...
    Test_OBJC_LIBS = -lUnitKit # you can link a tested library or framework

    include $(GNUSTEP_MAKEFILES)/bundle.make

Then, just type:

	ukrun Test.bundle

And you should have the list of the tests and their status. You can omit the
'Test.bundle' argument, if you do so ukrun will try to run any bundles (with 
.bundle extension) located in the current directory.


UnitTests Utility
-----------------

It is still in very rough state, but you can take a look at it in the repository 
just here: /trunk/Etoile/Developer/Services/UnitTests
