package blang.inits;

import blang.inits.GlobalArg;
import blang.inits.experiments.Experiment;
import blang.inits.experiments.ExperimentResults;

public class TestExperiment extends Experiment
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
  
  
//  char[] chars = new char[100*1024*1024];
//  Arrays.fill(chars, 'A');
//  String text = new String(chars);
//  long start = System.nanoTime();
//  BufferedWriter bw = new BufferedWriter(new FileWriter("/tmp/a.txt"));
//  bw.write(text);
//  bw.close();
//  long time = System.nanoTime() - start;
//  System.out.println("Wrote " + chars.length*1000L/time+" MB/s.");


}
