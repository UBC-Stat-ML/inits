package blang.inits

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
      @InitService TypeLiteral<?> type,
      @InitService Creator childCreator
    ) {
      println("qName = " + qName) // qName = someName
      
      // access generic information that would be otherwise type erased 
      // if it would not be instantiated in a managed way
      println("type = " + type)   // type = blang.inits.InitServiceExample$Bot<java.lang.String>
      
      /**
       * You can also get a child creator, which picks up the
       * same globals and parsers, and can be used e.g. to parse entries in a file, 
       * etc.
       */
      childCreator.init(Another, PosixParser.parse())
    }
  }
  
  static class Another {
    @Arg Deeper deeper
  }
  
  static class Deeper {
    @DesignatedConstructor
    new(
      @InitService QualifiedName qName,
      @GlobalArg   Global global
    ) {
      println("child qName = " + qName) // child qName = someName.deeper 
      println("global = " + global)     // global = global!
    }
  }
  
  def static void main(String [] args) {
    val Creator c = Creators.conventional()
    c.addGlobal(Global, new Global)
    try { c.init(Top, PosixParser.parse()) } catch (Exception e) {}
    println(c.errorReport)
  }
  
  static class Global {
    override toString() { "global!" }
  }
}