package blang.inits.experiments;

import java.io.File;
import java.util.Optional;

import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.inits.experiments.tabwriters.TabularWriterFactory;
import blang.inits.experiments.tabwriters.factories.CSV;

public class ExperimentConfigs
{
  @Arg(description = "Automatically organize results into subdirectories of 'results/all'?") 
                           @DefaultValue("true")
  public boolean managedExecutionFolder = true;
  
  @Arg(description = "Save combined standard out and err into a file?") 
                        @DefaultValue("true")
  public boolean saveStandardStreams = true;
  
  @Arg            @DefaultValue("false")
  public boolean recordGitInfo = false;

  @Arg(description = "Record information such as timing, main class, code version, etc for this run?") 
                        @DefaultValue("true")
  public boolean recordExecutionInfo = true;
  
  @Arg(description = "If set, use those arguments in provided file that do not appear in the provided arguments.")
  public Optional<File> configFile = Optional.empty();
  
  @Arg(description = "Documentation for this run.")
  public Optional<String> description = Optional.empty();
  
  @Arg(description = "Use -1 to silence all output")                        
                              @DefaultValue("inf")
  public int maxIndentationToPrint = Integer.MAX_VALUE;
  
  @Arg                             @DefaultValue("CSV")
  public TabularWriterFactory tabularWriter = new CSV();
}