package blang.inits;

import blang.inits.experiments.Cores;
import blang.inits.experiments.Experiment;

public class CoreTest extends Experiment
{
  @DefaultValue("Dynamic")
  @Arg Cores cores = Cores.dynamic();
  
  @Arg @DefaultValue("Fixed") Cores cores2 = Cores.single();
  
  @Override
  public void run() 
  {
    System.out.println(cores.numberAvailable());  
    System.out.println(cores2.numberAvailable());  
  }
  
  public static void main(String [] args)
  {
    Experiment.startAutoExit(args);
  }


}
