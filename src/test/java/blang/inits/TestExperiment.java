package blang.inits;

import java.util.Arrays;

import org.eclipse.xtext.xbase.lib.Pair;
import org.junit.Assert;

import blang.inits.GlobalArg;
import blang.inits.experiments.Experiment;
import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.TabularWriter;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.factories.CSV;
import blang.inits.experiments.tabwriters.factories.Spark;

public class TestExperiment extends Experiment
{
  @Arg @DefaultValue("world!")
  public String option;
  
  @GlobalArg
  public ExperimentResults result;
  
  @Arg @DefaultValue({"--test", "123"})
  public Custom c;
  
  @Arg @DefaultValue("AnImpl")
  public AnInter a;
  
  public static class Custom
  {
    @Arg
    int test;
  }
  
  @Implementations(AnImpl.class)
  public static interface AnInter
  {
    
  }
  
  public static class AnImpl implements AnInter
  {
    
  }

  @Override
  public void run()
  {
    System.out.println("Running");
    result.getAutoClosedPrintWriter("test").append("Hello " + option);
    
    { // example of correct usage of default (command line provided) TabularWriter
      TabularWriter csv = result.getTabularWriter("my-results");
      
      for (int i = 0; i < 10; i++)
        printSomeResults(csv.child("iteration", i));
    }
    
    { // example of incorrect usage
      TabularWriter csv = result.getTabularWriter("my-results");
      
      for (int i = 0; i < 10; i++)
        printSomeResults(csv.child("iteration", i));
      
      try {
        csv.write(Pair.of("label", "xx"));
        System.out.println("SHOULD NOT GET HERE!");
      }
      catch (Exception e) {
        System.out.println("error correctly caught: " + e);
      }
    }
    
    for (TabularWriterFactory impl : Arrays.asList(new CSV(), new Spark()))
    {
    
      { // example of correct usage of provided TabularWriter
        TabularWriter csv = result.getTabularWriter("my-results-" + impl.getClass().getSimpleName(), impl);
        
        for (int i = 0; i < 10; i++)
          printSomeResults(csv.child("iteration", i));
      }
    
    }
  }
  
  private void printSomeResults(TabularWriter writer) 
  {
    for (String label : new String[]{"one", "two"})
      writer.write(Pair.of("label", label));
  }
  

  public static void main(String [] args) 
  {
    Experiment.start(args);
  }

}
