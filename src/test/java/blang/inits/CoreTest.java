package blang.inits;

import blang.inits.experiments.Cores;
import blang.inits.experiments.Experiment;

public class CoreTest extends Experiment
{
  @Arg Cores cores = Cores.maxAvailable();
  
  @Arg @DefaultValue("1") Cores cores2 = new Cores(1);
  
  @Override
  public void run() 
  {
    System.out.println(cores.available);  
    System.out.println(cores2.available);  
  }
  
  public static void main(String [] args)
  {
    Experiment.startAutoExit(args);
  }


}
