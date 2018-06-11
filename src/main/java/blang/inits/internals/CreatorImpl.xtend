package blang.inits.internals

import blang.inits.parsing.Arguments
import blang.inits.parsing.QualifiedName
import blang.inits.internals.InitDependency
import blang.inits.internals.InitStaticUtils
import blang.inits.internals.InputDependency
import blang.inits.InputExceptions
import blang.inits.InputExceptions.InputException
import blang.inits.internals.IntrospectionSchema
import blang.inits.internals.Logger
import blang.inits.internals.Schema
import com.google.inject.TypeLiteral
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Map
import java.util.Optional
import java.util.Set
import blang.inits.Creator
import java.lang.reflect.Executable
import com.google.common.collect.ListMultimap
import java.lang.reflect.Method
import blang.inits.ProvidesFactory
import java.lang.reflect.InvocationTargetException
import blang.inits.Implementations
import briefj.BriefMaps
import blang.inits.InputExceptions.InputExceptionCategory

package class CreatorImpl implements Creator {
  val package Map<Class<?>, Object> globals = new HashMap
  
  // type initialized -> (static method to do so, type where this static method is defined)
  val package Map<Class<?>, Pair<Executable,TypeLiteral<?>>> factories = new HashMap
  
  var public transient Logger logger = null
  var transient Arguments lastArgs = null
  
  /**
   * @throws InputExceptions.FAILED_INIT if there is some
   * error; use errorReport() and errors() to access them.
   */
  override <T> T init(
    TypeLiteral<T> type,  
    Arguments args) {
    if (type === null || args === null) {
      throw new RuntimeException
    }
    // empty logs
    logger = new Logger
    lastArgs = args
    val T result = _init(type, args)  
    if (result === null || logger.hasUnknownArgument()) {
      throw InputExceptions.FAILED_INIT
    }
    return result
  }
   
  override String fullReport() {
    return logger.fullReport(lastArgs)
  }
  
  override Map<String,String> asMap() {
    checkInitialized()
    return logger.asMap()
  }
  
  override String usage() {
    checkInitialized()
    return logger.usage()
  }
  
  override String errorReport() {
    checkInitialized()
    return logger.errorReport()
  }
  
  override ListMultimap<QualifiedName,InputException> errors() {
    checkInitialized()
    return logger.errors
  }
    
  /**
   * null if failed (NOT optional, since the user will ask to instantiate optionals
   * something to mark optional command line arguments)
   */
  def package <T> T _init(
    TypeLiteral<T> declaredType, 
    Arguments currentArguments) 
  {
    try {
      InitStaticUtils::makeOptionalChecks(declaredType)
      var TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(declaredType)
      if (isCLILoadedInterface(declaredType)) { 
        return _initInterface(deOptionized, declaredType, currentArguments)
      } else {
        return _initActualType(deOptionized, declaredType, currentArguments)
      }
    } catch (InputException e) {
      logger.addError(currentArguments.QName, e)
      return null
    }
  }
  
  def <T> boolean isCLILoadedInterface(TypeLiteral<T> declaredType) {
    try {
      var TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(declaredType)
      return !factories.containsKey(deOptionized.rawType) && InitStaticUtils::needToLoadImplementation(deOptionized)
    } catch (Exception e) {
      // errors can happen e.g. if using raw type Optional
      // they should have already been reported by  makeOptionalChecks()
      return false
    }
  }
  
  /**
   * Assumes called by _init, so that:
   * - actualType is not an Optional<T> nor an interface, but rather the actual type
   *   to instantiate in both case (respectively, T, and the implementing class)
   * - we are covered in a try - catch bloc
   * 
   */                            // examples of arguments:
  def private <T> T _initActualType( //  for optionals        for interfaces
    TypeLiteral<?> actualType,   // e.g. Integer              ArrayList<String>
    TypeLiteral<T> declaredType, // e.g. Optional<Integer>    List<String>
    Arguments currentArguments
  ) {
    val boolean optional = InitStaticUtils::isOptional(declaredType)

    val Schema schema = 
      try {
        findSchema(actualType) 
      } catch (InputException ie) {
        if (ie.category == InputExceptionCategory.MALFORMED_BUILDER && optional)
          return (Optional.empty as Object) as T
        else 
          throw ie
      }
    val List<InitDependency> deps = schema.dependencies()
    val List<Object> instantiatedChildren = new ArrayList
    for (InitDependency initDependency : deps) {
      instantiatedChildren.add(initDependency.resolve(this, currentArguments)) 
    } 
    checkNoUnrecognizedArguments(currentArguments, deps)
    reportTypeUsage(declaredType, currentArguments, deps)
    
    if (optional && currentArguments.isNull()) { // only allow empty if no child argument were provided
      return (Optional.empty as Object) as T
    }
    
    if (InitStaticUtils::dependenciesOk(instantiatedChildren)) {
      try {
        val Object instance = schema.build(instantiatedChildren)
        return (
          if (optional) Optional.of(instance) else instance
        ) as T
      } catch (InvocationTargetException ite) {
        logger.addError(currentArguments.QName, InputExceptions::failedInstantiation(actualType, currentArguments.argumentValue, ite.targetException))
        return null
      } catch (Exception e) {
        logger.addError(currentArguments.QName, InputExceptions::failedInstantiation(actualType, currentArguments.argumentValue, e))
        return null
      }
    } else {
      if (!deps.filter(InputDependency).empty && !currentArguments.argumentValue.present) {
        logger.addError(currentArguments.QName, InputExceptions::missingInput(actualType))     
      } 
      return null
    }
  }
  
  def private <T> T _initInterface( 
    TypeLiteral<?> deOptionizedType,   
    TypeLiteral<T> declaredType, 
    Arguments currentArguments
  ) {
    val Pair<Arguments, Optional<String>> pair = currentArguments.pop
    if (!pair.value.isPresent) { // either the --key does not occur or has no input attached to it
      if (InitStaticUtils::isOptional(declaredType)) {
        return (Optional.empty as Object) as T
      } else {
        logger.addError(currentArguments.QName, InputExceptions::malformedImplementation(deOptionizedType, InitStaticUtils::implementations(declaredType)))
      }
      return null
    }
    // try to load the implementation
    val Class<?> rawType = try {
      val String implementationTypeString = pair.value.get
      findImplementation(implementationTypeString, deOptionizedType)
    } catch (Exception e) {
      logger.addError(currentArguments.QName, InputExceptions::malformedImplementation(deOptionizedType,InitStaticUtils::implementations(declaredType)))
      return null
    }
    
    // current limitation: still losing generic type information
    // in some cases here
    // general case not trivial, e.g. given:
    // - MyClass<T> implements MyInterface<Collection<T>>, 
    // - MyInterface<List<Integer>>
    // need to reverse engineer T = Integer
    // might be possible using guava's TypeToken instead of 
    // guice's TypeLiteral, but leave for later
    val TypeLiteral<?> actualType = TypeLiteral.get(rawType)
    
    if (!declaredType.rawType.isAssignableFrom(actualType.rawType)) {
      logger.addError(currentArguments.QName, InputExceptions::malformedImplementation(deOptionizedType, "Type " + actualType.rawType + " does not conform " + declaredType.rawType))
      return null
    }
    
    return _initActualType(actualType, declaredType, pair.key) as T 
  }
    
  def private Schema findSchema(TypeLiteral<?> currentType) {
    // Special treatment for enums
    if (currentType.rawType.isEnum()) {
      return new EnumSchema(currentType.rawType)
    }
    // else, use an introspection based scheme
    val pair = factories.get(currentType.rawType)
    if (pair !== null) {
      // use the database of factories in priority
      return new IntrospectionSchema(currentType, pair.value, pair.key)
    } else {
      // else, look in the type itself
      val builder = InitStaticUtils::findBuilder(currentType)
      if (builder.isPresent) {
        return new IntrospectionSchema(currentType, currentType, builder.get)
      } else {
        throw InputExceptions.malformedBuilder(currentType)
      }
    }
  }
  
  def Class<?> findImplementation(String requestedImpl, TypeLiteral<?> literal) {
    val Implementations impls = literal.rawType.getAnnotation(Implementations)
    if (impls !== null) {
      for (Class<?> impl : impls.value) {
        if (impl.simpleName.toLowerCase == requestedImpl.toLowerCase) {
          return impl
        }
      }
    }
    // if not found, try full qualified
    return Class.forName(requestedImpl)
  }
  
  private def void reportTypeUsage(
    TypeLiteral<?> typeOrOptional, 
    Arguments argument, 
    List<InitDependency> deps 
  ) {
    logger.allTypes.put(argument.QName, typeOrOptional)
    for (InitDependency dep : deps) {
      switch (dep) {
        InputDependency : {
          logger.inputsTypeUsage.put(argument.QName, typeOrOptional)
          logger.inputsDescriptions.put(argument.QName, dep.inputDescription)
          if (argument.argumentValue.present) {
            BriefMaps.getOrPutList(logger.readValues, argument.QName).addAll(argument.argumentValue.get)
          }
        }
        RecursiveDependency : {
          if (isCLILoadedInterface(dep.type)) {
            logger.inputsTypeUsage.put(argument.QName.child(dep.name), dep.type) 
            logger.inputsDescriptions.put(argument.QName.child(dep.name), interfaceUsageString(dep.type))
            if (argument.child(dep.name).argumentValue.present) {
              logger.readValues.put(argument.QName.child(dep.name), argument.child(dep.name).argumentValue.get)
            }
          }
          
          if (dep.defaultArguments.present) {
            logger.defaultValues.put(argument.QName.child(dep.name), dep.defaultArguments.toString)
            logger.defaultValuesRecursive.put(argument.QName.child(dep.name), dep.defaultArguments.isRecursive)
          }
          if (dep.description.present) { 
            logger.dependencyDescriptions.put(argument.QName.child(dep.name), dep.description.get)
          }
        }
        // do not report the other ones (globals, etc)
        default : {}
      }
    }
  }
  
  def static private String interfaceUsageString(TypeLiteral<?> type) {
    val List<String> shortcuts = new ArrayList(InitStaticUtils::implementations(type))
    shortcuts.add("fully qualified")
    return shortcuts.join("|")    
  }
  
  def private void checkNoUnrecognizedArguments(Arguments arguments, List<InitDependency> dependencies) {
    val Set<String> remainingChildren = new LinkedHashSet(arguments.childrenKeys)
    for (InitDependency dep : dependencies) {
      switch (dep) {
        RecursiveDependency : {
          remainingChildren.remove(dep.name)
        }
      }
    }
    for (String remainingChild : remainingChildren) {
      logger.addError(arguments.QName.child(remainingChild), InputExceptions.UNKNOWN_INPUT)
    }
  }
  
  override void addFactories(Class<?> factoryFile) {
    // TODO: find factories and add them
    val TypeLiteral<?> lit = TypeLiteral.get(factoryFile)
    for (Method m : factoryFile.declaredMethods) {
      if (m.getAnnotation(ProvidesFactory) !== null) {
        factories.put(m.returnType, m -> lit)
      }
    }
  }
  
  override <T> void addGlobal(Class<T> type, T object) {
    checkNotInitialized()
    globals.put(type, object)
  }
  
  def boolean isInitialized() {
    return logger !== null
  }
  
  def void checkNotInitialized() {
    if (isInitialized()) {
      throw new RuntimeException("The method init(..) must be called only after all setup-related functions are called.")
    }
  }
  
  def void checkInitialized() {
    if (!isInitialized()) {
      throw new RuntimeException("The method init(..) must be called before accessing result-related information.")
    }
  }
  
  package new() {}
}