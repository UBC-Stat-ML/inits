package blang.input

import blang.inits.Arguments
import blang.inits.QualifiedName
import blang.input.internals.InputExceptions.InputException
import blang.input.internals.Parser
import com.google.inject.TypeLiteral
import java.util.Map

interface Creator {
  
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