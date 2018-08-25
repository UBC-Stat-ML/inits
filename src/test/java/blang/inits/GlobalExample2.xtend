package blang.inits

import org.eclipse.xtend.lib.annotations.Data
import blang.inits.Arg
import blang.inits.parsing.Posix
import java.io.File
import briefj.BriefIO
import blang.inits.experiments.Experiment
import org.junit.Assert

/**
 * It is possible to add global objects which are accessible at all 
 * locations of the hierarchy. This is basically used to combine 
 * guice-style dependency injection.
 */
class GlobalExample2  extends Experiment {
  
  @GlobalArg GlobalType global
  
  override run() {
    println("--> " + global.number)
  }
  
  static class GlobalType {
    @Arg int number
  }
  
  def static void main(String [] args) {
    
    val file = File::createTempFile( "config", "txt") => [deleteOnExit]
    BriefIO::write(file, "--number 123")
    
    val result = Experiment.start(#[
      "--experimentConfigs.globalsClasses", "blang.inits.GlobalExample2$GlobalType", 
      "--experimentConfigs.globalsConfigFiles", file.absolutePath])
      
    Assert.assertEquals(result, 0)
  }
  

  
}
