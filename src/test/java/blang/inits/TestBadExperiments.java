package blang.inits;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import blang.inits.experiments.Experiment;

public class TestBadExperiments extends Experiment
{
  
  // Not so easy to test as is, 
//  @Rule
//  public TemporaryFolder folder= new TemporaryFolder();
//  
//  @Test
//  public void testProgramException()
//  {
//    main(new String[]{"--experimentConfigs.managedExecutionFolder", "false"});
//  }

  @Override
  public void run()
  {
    throw new RuntimeException("Test program exc");
  }
  
  public static void main(String [] args)
  {
    Experiment.startAutoExit(args);
  }

}
