package blang.inits

import blang.inits.experiments.Experiment
import blang.inits.experiments.tabwriters.TidySerializer
import blang.inits.experiments.tabwriters.TabularWriter
import java.util.Arrays
import blang.inits.experiments.ExperimentResults

class TestTidySerializer extends Experiment {
  
  @Arg CustomTidy tidy
  
  def static void main(String [] args) {
    Experiment::start(args)
  }
  
  override run() {
    {
      val SomeCustomClass testC = new SomeCustomClass
      testC.o1 = Arrays.asList(1,2,3)
      testC.o2 = Arrays.asList(4,5)
      tidy.serialize(testC, "test1") 
    }
    
    {
      val double [][] test = #[ #[2.0, 40.0], #[2.0, 40.0]]
      tidy.serialize(test, "test2") 
    }
  }
  
  static class SomeCustomClass
  {
    Object o1
    Object o2
  }
  
  static class CustomTidy extends TidySerializer
  {
    @DesignatedConstructor
    new(@GlobalArg ExperimentResults result) {
      super(result)
    } 
    
    def dispatch protected void serializeImplementation(SomeCustomClass object, TabularWriter writer) {
      recurse(object.o1, "ox", 1, writer)
      recurse(object.o2, "ox", 2, writer)
    }
  }
  
}