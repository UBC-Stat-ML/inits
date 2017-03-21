package blang.inits;

import blang.inits.GlobalArg;
import blang.inits.experiments.Experiment;
import blang.inits.experiments.ExperimentResults;

public class Test extends Experiment
{
  @Arg @DefaultValue("world!")
  public String option;
  
  @GlobalArg
  public ExperimentResults result;

  @Override
  public void run()
  {
    System.out.println("Running");
    result.getAutoClosedPrintWriter("test").append("Hello " + option);
  }
  
  public static void main(String [] args) 
  {
    Experiment.start(args);
  }

}
