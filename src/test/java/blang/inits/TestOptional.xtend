package blang.inits

import org.junit.Test
import blang.inits.parsing.Posix
import java.util.Optional

class TestOptional {
  
  @Arg
  Optional<Bad> optional 
  
  /* special corner case: for Blang's purpose, we want to allow skipping specification 
   * of constructors for optionals
   */
   
   static class Bad {
     
     new (int i) {
       
     }
     
     new (int i, int j) {
       
     }
     
   }
   
   @Test
   def void test() {
     val Creator creator = Creators.conventional()
     val instance = creator.init(
       TestOptional, 
       Posix.parse()  
     )
     println(creator.fullReport)
   }
  
}