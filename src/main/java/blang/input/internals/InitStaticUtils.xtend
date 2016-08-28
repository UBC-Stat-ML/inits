package blang.input.internals

import blang.inits.ConstructorArg
import blang.inits.Input
import com.google.inject.TypeLiteral
import java.lang.annotation.Annotation
import java.lang.reflect.Parameter
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

package class InitStaticUtils {
  
  def static Optional<String> optionalizeString(String str) {
    if (StringUtils.isEmpty(str)) {
      return Optional.empty
    } else {
      return Optional.of(str)
    }
  }
  
  def static InitDependency findDependency(TypeLiteral<?> literal, AnnotatedElement element, Optional<String> name) {
    val Annotation annotation = try {
      findAnnotation(element) 
    } catch (Exception e) {
      throw InputExceptions.malformedAnnotation(e.message, literal, element) 
    }
    return switch (annotation) {
      Arg : {
        new RecursiveDependency(literal, name.get, optionalizeString(annotation.description))
      }
      ConstructorArg : {
        new RecursiveDependency(literal, annotation.value, optionalizeString(annotation.description))
      }
      Input : {
        new InputDependency()
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
      val Constructor<?> zeroArg = try {
        type.rawType.getConstructor()
      } catch (Exception e) {
        null
      }
      if (zeroArg !== null) {
        found = Optional.of(zeroArg)
      }
    }
    if (found.present) {
      return found.get
    } else {
      throw InputExceptions.missingBuilder(type)
    }
  }
    
  val public static Set<Class<? extends Annotation>> possibleAnnotations = new LinkedHashSet(#[Input, ConstructorArg, Arg])
  
//  static private class GlobalDependency implements InitDependency {
//    
//    override Object resolve(Creator creator, Arguments currentArguments) {
//      
//    }
//    
//  }
 
  def static boolean dependenciesOk(List<Object> deps) {
    return !deps.contains(null)
  }
    
  def static <T> TypeLiteral<?> targetType(TypeLiteral<T> typeOrOptional) {
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