package blang.input

import blang.inits.Arg
import blang.inits.PosixParser

/**
 * Walking throug some simple usage examples.
 * 
 * Note that this is shown in Xtend, but usage in Java is virtually identical. 
 */
class Example {
  /**
   * Let's say we are interested in creating command line arguments
   * for the following class:
   */
  static class MyClass {
    
    /**
     * All we need to do is (1) add the "@Arg" annotation to all 
     * parameters we want to parse
     */
    @Arg
    public Integer anInteger
    
    /**
     * Make sure there is a zero-arg constructor available 
     * (other options available, see below).
     */
    new() {}
  }
  
  /**
   * That's it! We can now create an instance 
   */
  def static void main(String [] args) {
    val Creator creator = Creator.conventionalCreator
    val instance = creator.init(
      MyClass, // Note: would be "MyClass.class" in Java
      PosixParser.parse("--anInteger", "123")  // or "PosixParser.parse(args)" to read from the command line
    )
    println(instance.anInteger) // 123
  }
  
}