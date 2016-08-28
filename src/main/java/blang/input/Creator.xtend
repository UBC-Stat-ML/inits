package blang.input

import blang.inits.Arguments
import blang.inits.QualifiedName
import com.google.inject.TypeLiteral
import blang.input.internals.ExposedInternals
import blang.input.InputExceptions.InputException
import java.util.List

interface Creator {
  
  def static conventionalCreator() {
    return ExposedInternals::conventionalCreator()
  }
  
  def static bareBoneCreator() { 
    return ExposedInternals::bareBoneCreator()
  }
  
  def <T> void addParser(Class<T> type, ParserFromList<T> parser)
  def <T> void addParser(Class<T> type, Parser<T> parser) {
    val ParserFromList<T> converted = [List<String> input | parser.parse(input.join(" ").trim)] 
    addParser(type, converted)
  }
  
  def <T> void addParser(TypeLiteral<T> type, ParserFromList<T> parser) 
  def <T> void addParser(TypeLiteral<T> type, Parser<T> parser) {
    val ParserFromList<T> converted = [List<String> input | parser.parse(input.join(" ").trim)] 
    addParser(type, converted)
  }
  
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