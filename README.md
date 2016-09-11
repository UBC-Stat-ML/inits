Summary [![Build Status](https://travis-ci.org/UBC-Stat-ML/inits.png?branch=master)](https://travis-ci.org/UBC-Stat-ML/inits) 
-------



``inits`` is a library used to create ("init") a tree-structured object graph from a parse tree. The main motivation is that this parse tree comes from command line arguments/config file.

The project was born as a need to automatically setup inputs/command line arguments for ``blang``, but ``inits`` also be useful on its own. 

``inits`` can be viewed as a dependency injection framework tailored to complex and hierarchical command line arguments/config files. Hence, ``inits`` provides more facilities to the objects being initialized than most command line parsing frameworks (features such as typed globals, access to non-erased generic type information, coherent qualified names for instantiated objects, support for interfaces, etc).


Installation
------------


There are several options available to install the package:

### Integrate to a gradle script

Simply add the following lines (replacing 1.0.0 by the current version (see git tags)):

```groovy
repositories {
 mavenCentral()
 jcenter()
 maven {
    url "https://ubc-stat-ml.github.io/artifacts/"
  }
}

dependencies {
  compile group: 'ca.ubc.stat', name: 'inits', version: '1.0.0'
}
```

### Compile using the provided gradle script

- Check out the source ``git clone git@github.com:alexandrebouchard/inits.git``
- Compile using ``./gradlew installDist``
- Add the jars in ``build/install/inits/lib/`` into your classpath

### Use in eclipse

- Check out the source ``git clone git@github.com:alexandrebouchard/inits.git``
- Type ``gradle eclipse`` from the root of the repository
- From eclipse:
  - ``Import`` in ``File`` menu
  - ``Import existing projects into workspace``
  - Select the root
  - Deselect ``Copy projects into workspace`` to avoid having duplicates


Usage
-----

See:

- [Simple example](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/BasicExample.xtend)
- [Complex types](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/ComplexTypesExample.xtend)
- [Custom type parsers](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/ComplexTypesExample.xtend)
- [Global dependency injection](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/GlobalExample.xtend)
- [Printing usage](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/UsageExample.xtend)
- [Initialization service for complex use cases](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/InitServiceExample.xtend)
- [Example of full reporting](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/FullReportExample.xtend)
- [Example of reading config file](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/inits/ConfigTest.xtend)


