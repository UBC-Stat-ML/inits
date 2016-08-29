package blang.inits

import blang.inits.Arguments
import blang.inits.QualifiedName
import com.google.inject.TypeLiteral
import blang.inits.InputExceptions.InputException
import java.util.List
import com.google.common.collect.ListMultimap

/**
 * The main tool provided by this repo. 
 * 
 * For an example of usage, see in the src/test directory, blang.inits.UsageExample
 * 
 */
interface Creator {
  
  /**
   * @throws InputExceptions.FAILED_INIT if there is some
   * error; use errorReport() and errors() to access them.
   */
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
  def ListMultimap<QualifiedName,InputException> errors() 
  
  def String fullReport()
  
  def void addFactories(Class<?> factoryFile) 
  
  def <T> void addGlobal(Class<T> type, T object)
}