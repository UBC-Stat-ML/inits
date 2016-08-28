package blang.input.internals

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
import blang.input.InputExceptions
import java.lang.reflect.AnnotatedElement
import blang.inits.Arg
import blang.input.GlobalArg
import java.lang.reflect.Modifier
import blang.input.InitService

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
    val Annotation annotation = try {
      findAnnotation(element) 
    } catch (Exception e) {
      throw InputExceptions.malformedAnnotation(e.message, childType, element) 
    }
    return switch (annotation) {
      Arg : {
        new RecursiveDependency(childType, name.get, optionalizeString(annotation.description))
      }
      ConstructorArg : {
        new RecursiveDependency(childType, annotation.value, optionalizeString(annotation.description))
      }
      GlobalArg : {
        new GlobalDependency(childType)
      }
      InitService : {
        new InitServiceDependency(parentType, childType, element)
      }
      Input : {
        if (childType.rawType == String) { 
          new InputDependency(false) 
        } else if (childType.rawType == List) {
          new InputDependency(true)
        } else {
          throw InputExceptions.malformedAnnotation("@" + Input.simpleName + " only applies to String or List<String> ", childType, element)
        }
      }
      default : throw new RuntimeException
    }
  }
  
  def static Annotation findAnnotation(AnnotatedElement p) {
    var Optional<Annotation> result = Optional.empty
    for (Annotation annotation : p.annotations) {
      if (possibleAnnotations.contains(annotation.annotationType)) {
        if (result.present) {
          throw new RuntimeException("Cannot have more than one annotation from " + possibleAnnotations)
        }
        result = Optional.of(annotation)
      }
    }
    if (!result.present) {
      throw new RuntimeException("Need at least one annotation from " + possibleAnnotations)
    }
    return result.get
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
    if (type.rawType == com.google.common.base.Optional) {
      throw InputExceptions::GUAVA_OPTIONAL
    }
    return type.rawType == Optional
  }
  
  def static TypeLiteral<?> getOptionalType(TypeLiteral<?> optionalType) {
    if (!(optionalType.type instanceof ParameterizedType)) {
      throw InputExceptions::RAW_OPTIONAL
    }
    return TypeLiteral.get((optionalType.type as ParameterizedType).actualTypeArguments.get(0))
  }
  
  private new() {}
}