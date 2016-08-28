package blang.inits

import blang.inits.Arg
import blang.inits.ConstructorArg
import blang.inits.DesignatedConstructor
import java.util.Optional
import blang.inits.Posix

/**
 * Tutorial assumes you read BasicExample.xtend in same folder.
 */
class ComplexTypesExample {
  
  /**
   * Suppose now we want to read in a custom type composed of 
   * several parts. Say, two complex number.
   */
  static class MyComplexClass {
    @Arg private ComplexNumber n1 // NB: instantiated fields can be private, but not final
    @Arg private ComplexNumber n2
  }
  
  static class ComplexNumber {
    
    val double real
    val double imaginary
    
    /**
     * Moreover, let's say we would like the imaginary part 
     * of the complex number to be optional on the command line.
     * 
     * To do so, we do two things:
     * (1) single out a custom constructor using the annotation "@DesignatedConstructor"
     * (2) use the "Optional" class to mark the imaginary part as optional.
     */
    @DesignatedConstructor
    new(
      @ConstructorArg("real")      double           real, 
      @ConstructorArg("imaginary") Optional<Double> imaginary
    ) {
      this.real = real
      this.imaginary = imaginary.orElse(0.0)
    }
  }
  
  /**
   * We can now create an instance as follows:
   */
  def static void main(String [] args) {
    val Creator creator = Creators.conventional()
    val instance = creator.init(
      MyComplexClass, 
      Posix.parse(
        "--n1.real", "123",  // note the '.' notation to navigate command line argument down the object graph being created
        "--n2.real", "45",   // these hierarchies can be arbitrarily deep
        "--n2.imaginary", "-1.34e2")  
    )
    println(instance.n1.imaginary) // 0.0
    println(instance.n2.real)      // 45.0
  }
}