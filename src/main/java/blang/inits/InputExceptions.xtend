package blang.inits

import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.inits.DesignatedConstructor
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Optional
import java.util.List
import java.lang.reflect.AnnotatedElement
import org.apache.commons.lang3.exception.ExceptionUtils

class InputExceptions {
  
  val public static final RuntimeException FAILED_INIT = new RuntimeException("Failed to init object. Use creator.errorReport and creator.errors for detail.")
  
  def static InputException malformedBuilder(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MALFORMED_BUILDER, 
      "Exactly one of the constructors/static builder in " + type + " should be marked with @" + DesignatedConstructor.simpleName
    )
  }
  
  def static InputException nonStaticBuilder(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MALFORMED_BUILDER, 
      "The builder in " + type + " should be static"
    )
  }
  
  def static InputException faultyDefaultValue(String rootMessage) {
    return new InputException(
      InputExceptionCategory.MALFORMED_ANNOTATION,
      "Could not parse default value, root cause: \n" + rootMessage
    )
  }
  
  def static InputException malformedImplementation(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MALFORMED_INTERFACE_IMPLEMENTATION, 
      "The input should point to an implementation of " + type + "\n" +
      "  specified either with a fully qualified string, or a class name\n" +
      "  assumed to reside in the same package as the interface " + type + "\n" +
      "  note: default package not supported\n" +
      "  note: children options can only be reported after this error is fixed"
    )
  }
  
  def static InputException missingGlobal(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MISSING_GLOBAL,
      "Missing global of type " + type
    )
  }
  
  def static InputException failedInstantiation(TypeLiteral<?> type, Optional<List<String>> input, Throwable e) {
    return new InputException(
      InputExceptionCategory.FAILED_INSTANTIATION,
      "Failed to build type <" + type + ">, possibly a parsing error\n" + 
      "  input: " + input.orElse(#[]).join(" ") + "\n" +
      "  cause: " + ExceptionUtils.getMessage(e)
    )
  }
  
  def static InputException missingInput(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MISSING_INPUT,
      "Did not instantiate <" + type + "> because of missing input"
    )
  }
  
  def static InputException malformedAnnotation(String message, TypeLiteral<?> type, AnnotatedElement p) {
    return new InputException(
      InputExceptionCategory.MALFORMED_ANNOTATION,
      message + " in type <" + type + ">, parameter <" + p + "> of the builder"
    )
  }
  
  val public static InputException GUAVA_OPTIONAL = 
    new InputException(InputExceptionCategory.MALFORMED_OPTIONAL, "The Optional is implemented with Guava's Optional, but it should be using java.util's")
  
  val public static InputException RAW_OPTIONAL = 
    new InputException(InputExceptionCategory.MALFORMED_OPTIONAL, "The Optional need a generic argument, raw type usage insufficient to infer required type")
  
  val public static InputException UNKNOWN_INPUT = 
    new InputException(InputExceptionCategory.UNKNOWN_INPUT, "Unknown input")
  
  @Data
  static class InputException extends RuntimeException {
    @Accessors(PUBLIC_GETTER)
    val InputExceptionCategory category
    val String message
    
    override String getMessage() {
      return message
    }
  }
  
  static enum InputExceptionCategory {
    MALFORMED_BUILDER, 
    FAILED_INSTANTIATION,
    MISSING_INPUT,
    UNKNOWN_INPUT,
    MALFORMED_ANNOTATION,
    MALFORMED_OPTIONAL, 
    MISSING_GLOBAL,
    MALFORMED_INTERFACE_IMPLEMENTATION
  }
  
  private new() {}
}