package blang.input

import blang.inits.DesignatedConstructor
import blang.inits.QualifiedName
import blang.inits.Arg
import blang.inits.PosixParser
import com.google.inject.TypeLiteral

class InitServiceExample {
  
  
  static class Top {
    @Arg Bot bot
  }
  
  static class Bot {
    @DesignatedConstructor
    new (
      @InitService QualifiedName qName,
      @InitService TypeLiteral<?> type
    ) {
      println("qName = " + qName)
      println("type = " + type)
    }
  }
  
  def static void main(String [] args) {
    val Creator c = Creator.conventionalCreator
    try { c.init(Top, PosixParser.parse()) } catch (Exception e) {}
    println(c.errorReport)
  }
  
}