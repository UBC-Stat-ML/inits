package blang.input

import blang.inits.DesignatedConstructor
import blang.inits.QualifiedName
import blang.inits.Arg
import blang.inits.PosixParser
import com.google.inject.TypeLiteral

class InitServiceExample {
  
  
  static class Top {
    @Arg Bot<String> someName
  }
  
  static class Bot<T> {
    @DesignatedConstructor
    new (
      @InitService QualifiedName qName,
      @InitService TypeLiteral<?> type
    ) {
      println("qName = " + qName) // qName = someName
      
      // access generic information that would be otherwise type erased 
      // if it would not be instantiated in a managed way
      println("type = " + type)   // type = blang.input.InitServiceExample$Bot<java.lang.String>
    }
  }
  
  def static void main(String [] args) {
    val Creator c = Creator.conventionalCreator
    try { c.init(Top, PosixParser.parse()) } catch (Exception e) {}
    println(c.errorReport)
  }
}