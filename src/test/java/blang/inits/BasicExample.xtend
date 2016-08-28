package blang.inits

import blang.inits.Arg
import blang.inits.Posix

/**
 * Walking through some simple usage examples.
 * 
 * Note that this is shown in Xtend, but usage in Java is virtually identical. 
 */
class BasicExample {
  /**
   * Let's say we are interested in creating command line arguments
   * for the following class:
   */
  static class MyClass {
    
    /**
     * All we need to do is: 
     * 
     * (1) add the "@Arg" annotation to all parameters we want to parse
     *     (the name of the command line is just the field name here).
     */
    @Arg
    public Integer anInteger
    
    /**
     * (2) Make sure there is a zero-arg constructor available 
     *     (more complex options also available).
     */
    new() {}
  }
  
  /**
   * That's it! We can now create an instance as follows:
   */
  def static void main(String [] args) {
    val Creator creator = Creators.conventional()
    val instance = creator.init(
      MyClass, // Note: would be "MyClass.class" in Java
      Posix.parse("--anInteger", "123")  // or "Posix.parse(args)" to read from the command line
    )
    println(instance.anInteger) // 123
    
    // You can also show a usage string for the last call of init(..) using:
    println(creator.usage)
    // --anInteger <Integer>
    
    // If there are errors, the call to init(..) returns an exception; 
    // but use the following to get a more comprehensive diagnostic:
    try {
      creator.init(MyClass, Posix.parse("--anInteger", "abc"))
    } catch (Exception e) { }
    println("number of errors: " + creator.errors.size()) // 1, intentionally
    println(creator.errorReport)
    // --anInteger: Failed to build type <class java.lang.Integer>, possibly a parsing error (input: abc)
  }
  
}