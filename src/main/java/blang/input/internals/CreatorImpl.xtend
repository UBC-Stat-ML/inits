package blang.input.internals

import blang.inits.Arguments
import blang.inits.QualifiedName
import blang.input.internals.InitDependency
import blang.input.internals.InitStaticUtils
import blang.input.internals.InputDependency
import blang.input.InputExceptions
import blang.input.InputExceptions.InputException
import blang.input.internals.IntrospectionSchema
import blang.input.internals.Logger
import blang.input.internals.ParserSchema
import blang.input.internals.Schema
import com.google.inject.TypeLiteral
import java.util.ArrayList
import java.util.HashMap
import java.util.LinkedHashSet
import java.util.List
import java.util.Map
import java.util.Optional
import java.util.Set
import blang.input.Creator
import blang.input.ParserFromList

package class CreatorImpl implements Creator {
  val package Map<Class<?>, ParserFromList<?>> parsersIndexedByRawTypes = new HashMap
  val package Map<Class<?>, Object> globals = new HashMap
  
  override <T> T init(Class<T> type, Arguments args) {
    return init(TypeLiteral.get(type), args) as T
  }
  
  /**
   * @throws InputExceptions.FAILED_INIT if there is some
   * error; use errorReport() and errors() to access them.
   */
  override <T> T init(
    TypeLiteral<T> type,  
    Arguments args) {
    // empty logs
    // call _init  
    logger = new Logger
    val T result = _init(type, args)  
    if (result === null) {
      throw InputExceptions.FAILED_INIT
    }
    return result
  }
  
  override String usage() {
    return logger.usage()
  }
  
  override String errorReport() {
    return logger.errors.map[logger.formatArgName(it.key) + ": " + it.value.message].join("\n")
  }
  
  override Iterable<Pair<QualifiedName,InputException>> errors() {
    return logger.errors
  }
    
  var Logger logger = null
  
  def Schema findSchema(TypeLiteral<?> currentType) {
    // enums
    if (currentType.rawType.isEnum()) {
      return new EnumSchema(currentType.rawType)
    }
    // try to find a simple parser based on type erased
    val parser = parsersIndexedByRawTypes.get(currentType.rawType)
    if (parser !== null) {
      return new ParserSchema(parser)
    }
    // else, introspection based scheme
    return new IntrospectionSchema(currentType, InitStaticUtils::findBuilder(currentType))
  }
  
  /**
   * Assumes called by _init, so that:
   * - actualType is not an Optional<T> nor an interface, but rather the actual type
   *   to instantiate in both case (respectively, T, and the implementing class)
   * - we are covered in a try - catch bloc
   * 
   */                            // examples of arguments:
  def package <T> T _initActualType( //  for optionals        for interfaces
    TypeLiteral<?> actualType,   // e.g. Integer              ArrayList<String>
    TypeLiteral<T> declaredType, // e.g. Optional<Integer>    List<String>
    Arguments currentArguments
  ) {
    val boolean optional = InitStaticUtils::isOptional(declaredType)
    val Schema schema = findSchema(actualType)
    val List<InitDependency> deps = schema.dependencies()
    val List<Object> instantiatedChildren = new ArrayList
    for (InitDependency initDependency : deps) {
      instantiatedChildren.add(initDependency.resolve(this, currentArguments))
    } 
    checkNoUnrecognizedArguments(currentArguments, deps)
    logger.reportTypeUsage(declaredType, currentArguments, deps)
    
    if (InitStaticUtils::dependenciesOk(instantiatedChildren)) {
      try {
        val Object instance = schema.build(instantiatedChildren)
        return (
          if (optional) Optional.of(instance) else instance
        ) as T
      } catch (Exception e) {
        logger.addError(currentArguments.QName, InputExceptions.failedInstantiation(actualType, currentArguments.argumentValue, e))
        return null
      }
    } else {
      return (
        if (optional && currentArguments.isNull()) {// only allow empty if no child argument were provided
          (Optional.empty as Object)
        } else {
          if (!deps.filter(InputDependency).empty && !currentArguments.argumentValue.present) {
            logger.addError(currentArguments.QName, InputExceptions.missingInput(actualType))     
          }
          null
        }
      ) as T
    }
  }
  
  /**
   * null if failed
   */
  def package <T> T _init(
    TypeLiteral<T> declaredType, 
    Arguments currentArguments) 
  {
    try {
      var TypeLiteral<?> currentType = InitStaticUtils::targetType(declaredType)
      
//      if (currentType.rawType.isInterface()) {
//        // TODO: cleaner with recursion, but need some care with the optionals
//        //       but good opportunity to shrink this method by a bit
//      }
      
      return _initActualType(currentType, declaredType, currentArguments)

    } catch (InputException e) {
      logger.addError(currentArguments.QName, e)
      return null
    }
  }
  
  def void checkNoUnrecognizedArguments(Arguments arguments, List<InitDependency> dependencies) {
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
  
  override <T> void addParser(Class<T> type, ParserFromList<T> parser) {
    parsersIndexedByRawTypes.put(type, parser)
  }
  
  override <T> void addGlobal(Class<T> type, T object) {
    globals.put(type, object)
  }
  
  package new() {}
}