package blang.input

import blang.inits.Arguments
import blang.inits.ConstructorArg
import blang.inits.DesignatedConstructor
import blang.inits.Input
import com.google.inject.TypeLiteral
import java.lang.annotation.Annotation
import java.lang.reflect.Constructor
import java.lang.reflect.Executable
import java.lang.reflect.Method
import java.lang.reflect.Parameter
import java.lang.reflect.ParameterizedType
import java.lang.reflect.Type
import java.util.ArrayList
import java.util.Collections
import java.util.LinkedHashSet
import java.util.List
import java.util.Optional
import java.util.Set
import org.eclipse.xtend.lib.annotations.Data
import java.util.Map
import java.util.HashMap
import org.eclipse.xtend.lib.annotations.Accessors

class Creator {
  
  @Accessors(PUBLIC_GETTER, PUBLIC_SETTER)
  val Map<Class<?>, Parser> parsers = new HashMap
  
  def private Creator() {}
  
  def static conventionalCreator() {
    val Creator result = new Creator
    ConventionalParsers::setup(result)
    return result
  }
  def static bareBoneCreator() { return new Creator() }
  
  def <T> T init(Class<T> type, Arguments args) {
    return init(TypeLiteral.get(type), args) as T
  }
  
  /**
   * throw 
   */
  def <T> T init(
    TypeLiteral<T> type,  
    Arguments args) {
    // empty logs
    // call _init  
    val T result = _init(type, args)  
    if (result === null) {
      throw FAILED_INIT
    }
    return result
  }
  
  val public static final RuntimeException FAILED_INIT = new RuntimeException("Failed to init object")
  
  /**
   * A plan to create instances of a class
   */
  static interface Schema {
    def Object build(List<Object> arguments)
    def List<InitDependency> dependencies()
  }
  
  static interface Parser {
    def Object parse(List<String> inputs)
  }
  
  /**
   * A plan based on a single "@Input" SimpleDependency, 
   * passed to a parser
   */
  @Data
  static class ParserSchema implements Schema {
    val Parser parser
    override List<InitDependency> dependencies() {
      return Collections.singletonList(new InputDependency())
    }
    
    override Object build(List<Object> arguments) {
      return parser.parse(arguments.get(0) as List<String>)
    }
  }
  
  def static InitDependency findDependency(TypeLiteral<?> literal, Parameter parameter) {
    val Annotation annotation = findAnnotation(parameter)
    return switch (annotation) {
      ConstructorArg : {
        new RecursiveDependency(literal, annotation.value)
      }
      Input : {
        new InputDependency()
      }
      default : throw new RuntimeException
    }
  }
  
  def static Annotation findAnnotation(Parameter p) {
      var Optional<Annotation> result = Optional.empty
      for (Annotation annotation : p.annotations) {
        if (possibleAnnotations.contains(annotation.annotationType)) {
          if (result.present) {
            throw new RuntimeException // TODO: report duplicate
          }
          result = Optional.of(annotation)
        }
      }
      if (!result.present) {
        throw new RuntimeException // TODO: one needs to be there
      }
      return result.get
    }
    
  val static Set<Class<?>> possibleAnnotations = new LinkedHashSet(#[Input, ConstructorArg])
  
  @Data
  static class IntrospectionSchema implements Schema {
    val TypeLiteral<?> type
    val Executable builder
    
    override List<InitDependency> dependencies() {
      val List<InitDependency> result = new ArrayList
      val List<Parameter> parameters = builder.parameters
      val List<TypeLiteral<?>> parameterTypes = type.getParameterTypes(builder)
      for (var int i = 0; i < parameters.size; i++) {
        // create some function that takes into account whether it's a global, etc
        val InitDependency dep = findDependency(parameterTypes.get(i), parameters.get(i))
        result.add(dep)
      }
      // TODO: add marked fields too? (1)
      return result
    }
    
    override Object build(List<Object> arguments) {
      // take a sublist of arg if need fields init (2)
      val Object [] argArray = arguments
      val Object result = switch (builder) {
        Constructor<?> : {
          builder.newInstance(argArray)
        }
        Method : {
          builder.invoke(null, argArray)
        }
        default : throw new RuntimeException
      }
      // init fields here (3)
      return result
    }
  }
  
  static private interface InitDependency {
    /**
     * return null if missing or error
     * (NOT optional, since it may be used by the user)
     */
    def Object resolve(Creator creator, Arguments currentArguments)
  }

  static private class InputDependency implements InitDependency {
    // val boolean optional
    // TODO: later, optional input so that we can have Optional<List<String>>
    // TODO: later, allow also String, Optional<String>
    override Object resolve(Creator creator, Arguments currentArguments) {
      // TODO: report parsing error if missing
      currentArguments.argumentValue.orElse(null)
    }
  }
  
//  static private class GlobalDependency implements InitDependency {
//    
//    override Object resolve(Creator creator, Arguments currentArguments) {
//      
//    }
//    
//  }
 
  @Data
  static private class RecursiveDependency implements InitDependency {
    val TypeLiteral<?> type
    val String name
    
//    /**
//     * Assumes it has "@ConstructorArg annotation
//     */
//    new(Parameter parameter) {
//      val ConstructorArg annotation = parameter.getAnnotation(ConstructorArg)
//      name = annotation.value()
//      val Type boxedType = parameter.parameterizedType
//      // TODO: report structure error if using Guava's Optional
//      if (Instantiator::getRawClass(boxedType) == Optional) {
//        // TODO: report structural error if the argument was not specified
//        type = (boxedType as ParameterizedType).actualTypeArguments.get(0)
//        optional = true
//      } else {
//        type = boxedType
//        optional = false
//      }
//    }
    
    override Object resolve(Creator creator, Arguments currentArguments) {
      return creator._init(type, currentArguments.child(name))
    }
  }
  
//  /**
//   * return ok?
//   */
//  def private boolean validateInput(
//    boolean accepts, 
//    boolean requires, 
//    boolean present
//  ) {
//    if        (!accepts && present) {
//      // TODO: log: did not expect parsed string
//      return false
//    } else if (requires && !present) {
//      // TODO: log: required parsed string did not find it
//      return false
//    } else {
//      return true
//    }
//  }
  
  def private static boolean dependenciesOk(List<Object> deps) {
    return !deps.contains(null)
  }
  
  def private static boolean isOptional(TypeLiteral<?> type) {
    // TODO: structural error if guava Optional
    return type.rawType == Optional
  }
  
  def private static TypeLiteral<?> getOptionalType(TypeLiteral<?> optionalType) {
    // TODO: structural error if using raw type
    return TypeLiteral.get((optionalType.type as ParameterizedType).actualTypeArguments.get(0))
  }
  
  def Schema findSchema(TypeLiteral<?> currentType) {
    // try to find a simple parser
    val Parser parser = parsers.get(currentType.rawType)
    if (parser !== null) {
      return new ParserSchema(parser)
    }
    // else, introspection based scheme
    return new IntrospectionSchema(currentType, findBuilder(currentType))
  }
  
  /**
   * null if failed
   */
  def private <T> T _init(
    TypeLiteral<T> typeOrOptional, 
    Arguments currentArguments) 
  {
    val boolean optional = isOptional(typeOrOptional)
    val TypeLiteral<?> currentType = targetType(typeOrOptional)
    
    // identify the builder method (either a constructor or a static one or from a data base of lambdas)
    val Schema schema = try {
      findSchema(currentType)
    } catch (Exception e) {
      // TODO: log structural error, e.g. if no macthed builder
      return null
    } 
    
    // TODO: later, if it's an interface and there is no builder, specialized behavior here
    // TODO: consume one item in the argument, recurse if class found, else return error
    
    val List<Object> instantiatedChildren = new ArrayList
//    val Set<String> remainingKeys = new LinkedHashSet(currentArguments.childrenKeys)
    for (InitDependency initDependency : schema.dependencies()) {
      instantiatedChildren.add(initDependency.resolve(this, currentArguments))
    } 
//    if (!remainingKeys.isEmpty()) {
//      // TODO: log error
//    }
    if (dependenciesOk(instantiatedChildren)) {
      try {
        val Object instance = schema.build(instantiatedChildren)
        return (
          if (optional) Optional.of(instance) else instance
        ) as T
      } catch (Exception e) {
        // TODO: log the error
      }
    } else {
      return (
        if (optional && currentArguments.isNull()) // only allow empty if no child argument were provided
          (Optional.empty as Object) 
        else 
          null
      ) as T
    }
    
    
    
    // construct a list of all the recursion calls to be made (both from builder, but also fields and methods if applicable)
       // keep track of input vs global input
    
    // error = false
    // compute the children
      // if a global input, just lookup, else, recurse
      // NOTE: drop support for other annotations, 
      // debox optional if needed
      // make the call
      // if recursion returns missing, 
        // if the arg is optional, add an Option.empty to list
        // if the arg is not optional, set error to true
      // else if recursion ok, add (perhaps boxed in optional)
      // log the information, whether it worked or not
      
      
        // check if strings need to be consumed 
//    var boolean error = validateInput(builder.acceptsInput, builder.requiresInput, currentArguments.argumentValue.present)
    
    

      // if the switch is there, parse inside a catch
      // log the information, whether it worked or not
      // if it fails return error
      // else return success
      
    // if error = true, return error
      
      
    // 
//    throw new RuntimeException
  }
  
  def private static <T> TypeLiteral<?> targetType(TypeLiteral<T> typeOrOptional) {
      if (isOptional(typeOrOptional)) {
        getOptionalType(typeOrOptional)
      } else {
        typeOrOptional
      }
  }
  
  /**
   * Find the static method or constructor marked with "@DesignatedConstructor"
   * Default to zero arg constructor.
   * 
   * TODO: check it's actually static
   * 
   * throws exceptions if not found (optional not enough since need to log)
   */
  def static Executable findBuilder(TypeLiteral<?> type) {
    var Optional<Executable> found = Optional.empty
    val execCollections = #[type.rawType.constructors, type.rawType.methods]
    for (execCollection : execCollections) {
      for (Executable exec : execCollection) {
        if (!exec.getAnnotationsByType(DesignatedConstructor).empty) {
          if (found.present) {
            throw new RuntimeException("Not more than one constructor/static factory should be marked with @" + DesignatedConstructor.simpleName)
          }
          found = Optional.of(exec)
        }
      }
    }
    if (!found.present)
    {
      // defaults to zero-arg constructor
      val Constructor<?> zeroArg = type.rawType.getConstructor()
      if (zeroArg !== null) {
        found = Optional.of(zeroArg)
      }
    }
    if (found.present) {
      return found.get
    } else {
      throw new RuntimeException("One of the constructors should be marked with @" + DesignatedConstructor.simpleName)
    }
  }
}