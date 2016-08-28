package blang.input

import org.eclipse.xtend.lib.annotations.Data
import com.google.inject.TypeLiteral
import blang.inits.DesignatedConstructor
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Optional
import java.util.List
import java.lang.reflect.Parameter

class InputExceptions {
  
  val public static final RuntimeException FAILED_INIT = new RuntimeException("Failed to init object")
  
  def public static InputException missingBuilder(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MISSING_BUILDER, 
      "One of the constructors/static builder in " + type.rawType + " should be marked with @" + DesignatedConstructor.simpleName
    )
  }
  
  def public static InputException failedInstantiation(TypeLiteral<?> type, Optional<List<String>> input) {
    return new InputException(
      InputExceptionCategory.FAILED_INSTANTIATION,
      "Failed to build type <" + type.rawType + ">, possibly a parsing error (input: " + input.orElse(#[]).join(" ") + ")"
    )
  }
  
  def public static InputException missingInput(TypeLiteral<?> type) {
    return new InputException(
      InputExceptionCategory.MISSING_INPUT,
      "Did not instantiate <" + type.rawType + "> because of missing input"
    )
  }
  
  def public static InputException malformedAnnotation(String message, TypeLiteral<?> type, Parameter p) {
    return new InputException(
      InputExceptionCategory.MALFORMED_ANNOTATION,
      message + " in type <" + type.rawType + ">, parameter <" + p + "> of the builder"
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
    MISSING_BUILDER, 
    FAILED_INSTANTIATION,
    MISSING_INPUT,
    UNKNOWN_INPUT,
    MALFORMED_ANNOTATION,
    MALFORMED_OPTIONAL
  }
  
  private new() {}
  
}