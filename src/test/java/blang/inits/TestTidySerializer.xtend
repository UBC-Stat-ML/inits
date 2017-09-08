package blang.inits

import blang.inits.experiments.Experiment
import blang.inits.experiments.tabwriters.TidySerializer
import blang.inits.experiments.tabwriters.TabularWriter
import java.util.Arrays
import blang.inits.experiments.ExperimentResults
import blang.inits.experiments.tabwriters.TidySerializer.ProvidesTidySerialization
import blang.inits.experiments.tabwriters.TidySerializer.Context

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
    
    tidy.serialize(new AnotherCustomClass, "test3")
  }
  
  static class SomeCustomClass
  {
    Object o1
    Object o2
  }
  
  static class AnotherCustomClass implements ProvidesTidySerialization {
    val list1 = #[1, 2, 3]
    val list2 = #[4, 5, 6]
    override serialize(Context context) {
      context => [
        recurse(list1, "field_idx", 1)
        recurse(list2, "field_idx", 2)
      ]
    }
    
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