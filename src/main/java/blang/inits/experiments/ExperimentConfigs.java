package blang.inits.experiments;

import blang.inits.Arg;
import blang.inits.DefaultValue;

public class ExperimentConfigs
{
  @Arg(description = "Automatically organize results into subdirectories of 'results/all'?") 
  @DefaultValue("true")
  public boolean managedExecutionFolder = true;
  
  @Arg(description = "Save combined standard out and err into a file?") 
  @DefaultValue("true")
  public boolean saveStandardStreams = true;

  @Arg(description = "Record information such as timing, main class, code version, etc for this run?") 
  @DefaultValue("true")
  public boolean recordExecutionInfo = true;
}