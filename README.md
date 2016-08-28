Summary
-------

<!-- [![Build Status](https://travis-ci.org/alexandrebouchard/inits.png?branch=master)](https://travis-ci.org/alexandrebouchard/inits) -->

``inits`` is a library used to create a tree-structured object graph from a parse tree (main motivation is that this parse tree comes from command line arguments/config file).

The project was born as a need to automatically setup inputs/command line arguments for ``blang``, but can also be useful on its own. 

It is also related to dependency injection frameworks such as Guice, but is geared towards a different use case, namely complex/hierarchical command line arguments/config files.


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

- [Simple example](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/input/BasicExample.xtend)
- [Complex types](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/input/ComplexTypesExample.xtend)
- [Custom type parsers](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/input/ComplexTypesExample.xtend)
- [Global dependency injection](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/input/GlobalExample.xtend)
- [Printing usage](https://github.com/UBC-Stat-ML/inits/blob/master/src/test/java/blang/input/UsageExample.xtend)
