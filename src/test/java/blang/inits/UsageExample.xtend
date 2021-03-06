package blang.inits

import blang.inits.Arg
import blang.inits.parsing.Posix
import java.util.Optional

class UsageExample {
  
  static class MyClass {
    @Arg(description = "description of this first integer")  int anInteger
    @Arg(description = "description of this second integer") int another
    @Arg Optional<Integer> finalOne
  }
  
  def static void main(String [] args) {
    val Creator c = Creators.conventional()
    try { c.init(MyClass, Posix.parse()) } catch(Exception e) {}
    // even if above fails, can still print usage info
    println(c.usage)
    /*
    
      --anInteger <int>
        description: description of this first integer
      --another <int>
        description: description of this second integer
    
     */ 
    println
    // report errors too:
    println(c.errorReport)
    /*
      
      @ anInteger: Did not instantiate <int> because of missing input
      @ another: Did not instantiate <int> because of missing input
       
     */
  }
  
}