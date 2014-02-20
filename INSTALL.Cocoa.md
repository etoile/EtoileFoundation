UnitKit Mac OS X and iOS INSTALL
================================

Required software
-----------------

In addition to Xcode 4 or higher, you need Mac OS X 10.6 or higher to compile 
UnitKit.

For test suites written with UnitKit, either Mac OS X 10.6 or higher, or iOS 5 
or higher are required to run them.


Build and Install
-----------------

For a simple build, open UnitKit.xcodeproj and choose ukrun in the Scheme menu.

To install in /Library/Frameworks, do the build in the shell: 

	sudo xcodebuild -target ukrun -configuration Release clean install


Test suite
----------

For runnings the tests that comes with UnitKit, open UnitKit.xcodeproj and 
choose TestUnitKit or TestUnitKit (iOS) in the Scheme menu.


Trouble
-------

Give us feedback! Tell us what you like; tell us what you think
could be better. Send bug reports and patches to <bug-etoile@gna.org>.
