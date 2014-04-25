UnitKit TODO
============

 - Perhaps change test bundle extension from 'bundle' to 'testbundle' or 'unitkit'
 
 - Declare implicit UKTestHandlerDelegate informal protocol

 - Move UKRunner tool support to a dedicated class UKTool or UKBundleLoader

 - Perhaps change the UKRunner API for running tests and adding test classes to: -addTestClassesNames:, -addTestClassesFromBundle: and -runWithPrincipalClass:.

 - Add -[UKRunner initWithHandler:] and retrieve the test handler in test macros with [[UKRunner runnerForObject: self] handler]

   - we could maintain a map of runners by test object, or just attach the runner with a 'UKRunner' associated reference
   - this would make possible to support handler subclasses cleanly and multiple simultaneous runners (each one using their own custom handler)

 - Support parameterized test class instantiation, the same test class being instantiated multiple times with various arguments (passed in a dictionary or an array)

   - the test class could implement an optional informal protocol that returns a collection containing each instantiation arguments (the collection element represent all the expected instantiatations)

 - Resurrect the old UnitTests utility, see http://svn.gna.org/viewcvs/etoile/trunk/Etoile/Developer/Services/UnitTests/

