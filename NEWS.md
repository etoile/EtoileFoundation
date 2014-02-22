UnitKit NEWS
============

1.5 (Etoile 0.4.3)
------------------

- Added abstract test case support (test methods from superclasses are now run by UKRunner)
- Added option to choose the tested classes (-c for a class list and -classRegex for list based on a pattern)
- Added uncaught exception reporting in the test results
- Better reporting for uncaught exceptions in -init and -dealloc
- Added class and method name printing in the test suite output
- Added iOS support
- Cleaned the code base and updated the documentation a lot 
- API documentation is now output with Etoile DocGenerator
- Updated Xcode support
- Added new Xcode file and project templates for Xcode 4 and higher
- Removed dependency on AppKit and Growl notification support (nobody used it)
- Removed -initForTest and -releasedForTest (proved to be a bad idea)

1.3 (Etoile 0.4)
----------------

- Added UKObjectKindOf test macro
- Lazy instantiation of the application class if needed. This allows to test EtoileUI-based code which use ETApplication instead of NSApplication
- Growl notifications on Mac OS X (borrowed from UnitKit 2.0 development that was never released)
- More useful feedback when an exception is raised while performing a test
- Fix for running the tests when NSProxy subclasses are present at runtime
- Updated Xcode support

1.2 (Etoile 0.2)
----------------

- Memory leak fixes

1.1 (Etoile 0.1)
----------------

- Updated UnitKit 1.0 GNUstep port to UnitKit 1.1 source code
	- Test classes and test methods are now executed in alphabetical order
	- Test methods are now run within the scope of a run loop
- Test class method support named like +testWhatever.
- Added -initForTest and -releaseForTest as an alternative to -init and -dealloc 

1.0
---

- First GNUstep release (this is not the same release than the one on Mac OS X)
