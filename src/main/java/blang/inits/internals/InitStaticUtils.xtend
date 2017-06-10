package blang.inits.internals

import blang.inits.ConstructorArg
import blang.inits.Input
import com.google.inject.TypeLiteral
import java.lang.annotation.Annotation
import java.lang.reflect.ParameterizedType
import java.util.LinkedHashSet
import java.util.List
import java.util.Optional
import java.util.Set
import org.apache.commons.lang3.StringUtils
import java.lang.reflect.Executable
import blang.inits.DesignatedConstructor
import java.lang.reflect.Constructor
import blang.inits.InputExceptions
import java.lang.reflect.AnnotatedElement
import blang.inits.Arg
import blang.inits.GlobalArg
import java.lang.reflect.Modifier
import blang.inits.InitService
import blang.inits.DefaultValue
import blang.inits.parsing.Arguments
import blang.inits.parsing.Posix
import blang.inits.Implementations
import java.util.Collections

package class InitStaticUtils {
  
  def static Optional<String> optionalizeString(String str) {
    if (StringUtils.isEmpty(str)) {
      return Optional.empty
    } else {
      return Optional.of(str)
    }
  }
  
  val public static Set<Class<? extends Annotation>> possibleAnnotations = new LinkedHashSet(
    #[
      Input, 
      ConstructorArg, 
      Arg, 
      GlobalArg,
      InitService
    ]
  )
  
  def static InitDependency findDependency(TypeLiteral<?> parentType, TypeLiteral<?> childType, AnnotatedElement element, Optional<String> name) {
    val Pair<Annotation,Optional<DefaultValue>> annotations = try {
      findAnnotation(element) 
    } catch (Exception e) {
      throw InputExceptions.malformedAnnotation(e.message, childType, element) 
    }
    val Annotation annotation = annotations.key
    val ParsedDefaults defaultArguments = defaultArguments(annotations.value)
    return switch (annotation) {
      Arg : {
        new RecursiveDependency(childType, name.get, optionalizeString(annotation.description), defaultArguments)
      }
      ConstructorArg : {
        new RecursiveDependency(childType, annotation.value, optionalizeString(annotation.description), defaultArguments)
      }
      GlobalArg : {
        new GlobalDependency(childType)
      }
      InitService : {
        new InitServiceDependency(parentType, childType, element)
      }
      Input : {
        val boolean isOptional = InitStaticUtils::isOptional(childType)
        val TypeLiteral<?> deOptionized = InitStaticUtils::deOptionize(childType)
        if (deOptionized.rawType == String) { 
          new InputDependency(false, isOptional, annotation.formatDescription) 
        } else if (deOptionized.rawType == List) {
          new InputDependency(true, isOptional, annotation.formatDescription)
        } else {
          throw InputExceptions.malformedAnnotation("@" + Input.simpleName + " only applies to String or List<String> ", childType, element)
        }
      }
      default : throw new RuntimeException
    }
  }
  
  def static ParsedDefaults defaultArguments(Optional<DefaultValue> defaultValueAnnotation) {
    if (defaultValueAnnotation.isPresent) {
      val boolean isRecursive = isRecursive(defaultValueAnnotation.get)
      if (isRecursive) {
        return ParsedDefaults.createRecursive(Posix.parse(defaultValueAnnotation.get.value))
      } else {
        return ParsedDefaults.createNonRecursive(defaultValueAnnotation.get.value)
      }
    } else {
      return ParsedDefaults.createEmpty
    }
  }
  
  def static boolean isRecursive(DefaultValue value) {
    val Arguments parsed = Posix.parse(value.value)
    return !parsed.childrenKeys.isEmpty
  }
  
  def static List<String> implementations(TypeLiteral<?> type) {
    val TypeLiteral<?> deOptionizedType = InitStaticUtils::deOptionize(type)
    val Implementations annotation = deOptionizedType.rawType.getAnnotation(Implementations)
    if (annotation == null) {
      return Collections::emptyList
    } else {
      return annotation.value.map[it.simpleName]
    }
  }
  
  def static Pair<Annotation,Optional<DefaultValue>> findAnnotation(AnnotatedElement p) {
    var Optional<Annotation> main = Optional.empty
    var Optional<DefaultValue> secondary = Optional.empty
    for (Annotation annotation : p.annotations) {
      if (annotation.annotationType == DefaultValue) {
        secondary = Optional.of(annotation as DefaultValue)
      } else if (possibleAnnotations.contains(annotation.annotationType)) {
        if (main.present) {
          throw new RuntimeException("Cannot have more than one annotation from " + possibleAnnotations)
        }
        main = Optional.of(annotation)
      }
    }
    if (!main.present) {
      throw new RuntimeException("Need at least one annotation from " + possibleAnnotations)
    }
    return Pair.of(main.get, secondary)
  }
  
  def static boolean needToLoadImplementation(TypeLiteral<?> deOptionized) {
    // if it has a builder which is static, certainly no need to resolve interface
    if (InitStaticUtils::hasBuilder(deOptionized) &&
        Modifier.isStatic(InitStaticUtils::findBuilder(deOptionized).get.modifiers)
    ) {
      return false
    }
    if (deOptionized.rawType.isPrimitive) {
      return false // to get around annoying bug in Java SDK: primitive types t => Modifier.isAbstract(t) = true
    }
    if (deOptionized.rawType.isEnum) {
      return false // we don't want enums with interfaces to be treated like standard interfaces
    }
    // otherwise, abstract classes and interface need to be resolved
    return deOptionized.rawType.isInterface() ||        
           Modifier.isAbstract(deOptionized.rawType.modifiers)
  }
  
  def static boolean hasBuilder(TypeLiteral<?> type) {
    return findBuilder(type).isPresent
  }
  
  /**
   * Find the static method or constructor marked with "@DesignatedConstructor"
   * Default to zero arg constructor.
   * 
   * TODO: check it's actually static
   * 
   * throws exceptions if not found (optional not enough since need to log)
   */
  def static Optional<Executable> findBuilder(TypeLiteral<?> type) {
    var Optional<Executable> found = Optional.empty
    val execCollections = #[type.rawType.constructors, type.rawType.methods]
    for (execCollection : execCollections) {
      for (Executable exec : execCollection) {
        if (!exec.getAnnotationsByType(DesignatedConstructor).empty) {
          if (found.present) {
            throw InputExceptions.malformedBuilder(type)
          }
          found = Optional.of(exec)
        }
      }
    }
    if (!found.present)
    {
      // defaults to zero-arg constructor
      val Constructor<?> zeroArg = try {
        type.rawType.getConstructor()
      } catch (Exception e) {
        null
      }
      if (zeroArg !== null) {
        found = Optional.of(zeroArg)
      }
    }
    return found
  }
 
  def static boolean dependenciesOk(List<Object> deps) {
    return !deps.contains(null)
  }
    
  def static <T> TypeLiteral<?> deOptionize(TypeLiteral<T> typeOrOptional) {
    if (InitStaticUtils::isOptional(typeOrOptional)) {
      InitStaticUtils::getOptionalType(typeOrOptional)
    } else {
      typeOrOptional
    }
  }
  
  def static boolean isOptional(TypeLiteral<?> type) {
    return type.rawType == Optional
  }
  
  def static TypeLiteral<?> getOptionalType(TypeLiteral<?> optionalType) {
    return TypeLiteral.get((optionalType.type as ParameterizedType).actualTypeArguments.get(0))
  }
  
  // Note: we only want to make these checks once to avoid duplicated error messages, so 
  // called by init() rather than the above methods
  def static void makeOptionalChecks(TypeLiteral<?> type) {
    if (type.rawType == com.google.common.base.Optional) {
      throw InputExceptions::GUAVA_OPTIONAL
    }
    if (InitStaticUtils::isOptional(type)) {
      if (!(type.type instanceof ParameterizedType)) {
        throw InputExceptions::RAW_OPTIONAL
      }
    }
  }
  
  private new() {}
}