package blang.input

import blang.inits.Arguments
import blang.inits.QualifiedName
import com.google.inject.TypeLiteral
import java.util.Map
import blang.input.internals.ExposedInternals
import blang.input.InputExceptions.InputException

interface Creator {
  
  def static conventionalCreator() {
    return ExposedInternals::conventionalCreator()
  }
  
  def static bareBoneCreator() { 
    return ExposedInternals::bareBoneCreator()
  }
  
  def Map<Class<?>, Parser> getParsers()
  
  def <T> T init(Class<T> type, Arguments args) {
    return init(TypeLiteral.get(type), args) as T
  }
  
  /**
   * @throws InputExceptions.FAILED_INIT if there is some
   * error; use errorReport() and errors() to access them.
   */
  def <T> T init(TypeLiteral<T> type, Arguments args) 
  
  def String usage() 
  
  def String errorReport() 
  
  def Iterable<Pair<QualifiedName,InputException>> errors() 
  
}