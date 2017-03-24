package blang.inits

import blang.inits.parsing.Arguments
import blang.inits.parsing.QualifiedName
import com.google.inject.TypeLiteral
import blang.inits.InputExceptions.InputException
import com.google.common.collect.ListMultimap
import java.util.Map

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
  
  /**
   * A detailed, human readable report containing
   * - instructions
   * - values used by last invocation, and whether they come from defaults or input
   * - errors
   */
  def String fullReport()
  
  /**
   * All (key,value) pairs used in last invocation, whether they come from default or input
   */
  def Map<String,String> asMap()
  
  def void addFactories(Class<?> factoryFile) 
  
  def <T> void addGlobal(Class<T> type, T object)
}