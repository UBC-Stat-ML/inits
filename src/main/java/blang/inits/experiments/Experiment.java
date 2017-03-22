package blang.inits.experiments;

import static briefj.BriefIO.write;
import static briefj.run.ExecutionInfoFiles.CLASSPATH_INFO;
import static briefj.run.ExecutionInfoFiles.DIRTY_FILE_RANDOM_HASH;
import static briefj.run.ExecutionInfoFiles.EXCEPTION_FILE;
import static briefj.run.ExecutionInfoFiles.GLOBAL_HASH;
import static briefj.run.ExecutionInfoFiles.JAVA_ARGUMENTS;
import static briefj.run.ExecutionInfoFiles.JVM_OPTIONS;
import static briefj.run.ExecutionInfoFiles.MAIN_CLASS_FILE;
import static briefj.run.ExecutionInfoFiles.REPOSITORY_INFO;
import static briefj.run.ExecutionInfoFiles.STD_OUT_FILE;
import static briefj.run.ExecutionInfoFiles.WORKING_DIR;
import static briefj.run.ExecutionInfoFiles.START_TIME_FILE;
import static briefj.run.ExecutionInfoFiles.END_TIME_FILE;
import static briefj.run.ExecutionInfoFiles.exists;
import static briefj.run.ExecutionInfoFiles.getExecutionInfoFolder;
import static briefj.run.ExecutionInfoFiles.getFile;

import java.io.File;
import java.lang.management.ManagementFactory;
import java.util.List;

import org.apache.commons.lang3.exception.ExceptionUtils;

import com.google.common.base.Joiner;
import com.google.common.hash.HashCode;

import blang.inits.Arg;
import blang.inits.Creator;
import blang.inits.Creators;
import blang.inits.GlobalArg;
import blang.inits.Inits;
import blang.inits.parsing.Arguments;
import blang.inits.parsing.Posix;
import briefj.BriefIO;
import briefj.BriefStrings;
import briefj.repo.RepositoryUtils;
import briefj.run.DependencyUtils;
import briefj.run.HashUtils;
import briefj.run.RedirectionUtils;
import briefj.run.RedirectionUtils.Tees;
import briefj.run.Results;

public abstract class Experiment implements Runnable
{
  @Arg
  public ExperimentConfigs experimentConfigs = new ExperimentConfigs();
  private static final String EXP_CONFIG_FIELD_NAME = "experimentConfigs";
  
  @GlobalArg
  public ExperimentResults results = new ExperimentResults(new File("."));
  
  public static void start(
      String [] args)
  {
    start(args, new ParsingConfigs());
  }

  public static void start(
      String [] args,
      ParsingConfigs configs)
  {
    Arguments arguments = Posix.parse(args);
    
    ExperimentConfigs expConfigs = preloadExperimentsConfigs(arguments.child(EXP_CONFIG_FIELD_NAME));
    if (expConfigs == null)
      return;
    
    ExperimentResults results = createExperimentResultsObject(expConfigs);
    configs.creator.addGlobal(ExperimentResults.class, results);
    
    Runnable experiment = null;
    try 
    {
      experiment = configs.creator.init(configs.findExperimentClass(), arguments);
    } 
    catch (Exception e) 
    {
      if (arguments.childrenKeys().contains(Inits.HELP_STRING)) 
        System.out.println(configs.creator.usage());
      else
        System.err.println(configs.creator.fullReport());
      cleanEmptyResultFolder(results, expConfigs);
      return;
    }
    
    // report command line options and some more
    Tees tees = !exists(STD_OUT_FILE) && expConfigs.saveStandardStreams ?
        RedirectionUtils.createTees(getExecutionInfoFolder()) :
        null;
    
    if (expConfigs.recordExecutionInfo) 
    {
      recordArguments(configs.creator, results);
      recordExecutionInfo(experiment, args);
    }
    
    long startTime = System.currentTimeMillis();
    
    if (expConfigs.recordExecutionInfo)
      write(
          getFile(START_TIME_FILE),
          "" + startTime);
    
    experiment.run();
    long endTime = System.currentTimeMillis();
    
    if (expConfigs.recordExecutionInfo)
      write(
          getFile(END_TIME_FILE),
          "" + endTime);
    
    if (tees != null)
      tees.close();
    
    System.out.println("executionMilliseconds : " + (endTime - startTime));
    System.out.println("outputFolder : " + Results.getResultFolder().getAbsolutePath());
    
    // close all streams
    results.closeAll();
  }
  
  public static final String CSV_ARGUMENT_FILE = "arguments.csv";
  public static final String DETAILED_ARGUMENT_FILE = "arguments-details.txt";
  
  private static void recordArguments(Creator creator, ExperimentResults results)
  {
    BriefIO.write(results.getFileInResultFolder(CSV_ARGUMENT_FILE), creator.csvReport());
    BriefIO.write(results.getFileInResultFolder(DETAILED_ARGUMENT_FILE), creator.fullReport());
  }

  private static void recordExecutionInfo(Runnable mainClass, String [] args)
  {
    // record main class
    write(
      getFile(MAIN_CLASS_FILE),
      mainClass.getClass().toGenericString());
      
    // record JVM options
    List<String> arguments = ManagementFactory.getRuntimeMXBean().getInputArguments();
    write(
      getFile(JVM_OPTIONS),
      Joiner.on(" ").join(arguments));
      
    // record pwd
    if (!exists(WORKING_DIR))
      write(
        getFile(WORKING_DIR),
        System.getProperty("user.dir"));
    
    // record raw arguments
    write(
      getFile(JAVA_ARGUMENTS),
      Joiner.on(" ").join(args));
    
    try
    {
      if (!exists(REPOSITORY_INFO))
        if (!RepositoryUtils.recordCodeVersion(mainClass))
          // if there were dirty file (i.e. not in version control) write a random string to avoid collisions
          write(
            getFile(DIRTY_FILE_RANDOM_HASH), 
            HashUtils.HASH_FUNCTION.hashUnencodedChars(BriefStrings.generateUniqueId()).toString());
    }
    catch (RuntimeException e)
    {
      System.err.println("WARNING: Bare Repository has neither a working tree, nor an index.");
      write(getFile(EXCEPTION_FILE), ExceptionUtils.getStackTrace(e));
    }

    if (!exists(CLASSPATH_INFO))
      DependencyUtils.recordClassPath();
    
    // global hash code of the execution inputs, repository, etc
    HashCode global = HashUtils.computeFileHashCodesRecursively(getExecutionInfoFolder());
    write(getFile(GLOBAL_HASH), global.toString());
  }

  private static void cleanEmptyResultFolder(ExperimentResults results, ExperimentConfigs expConfigs)
  {
    if (expConfigs.managedExecutionFolder)
    {
      File result = results.resultsFolder;
      File poolFolder = result.getParentFile().getParentFile(); // up one is 'all', up two is 'results'
      File latestFolderSoftLink = new File(poolFolder, Results.LATEST_STRING);
      latestFolderSoftLink.delete();
      result.delete();
    }
  }

  private static ExperimentResults createExperimentResultsObject(ExperimentConfigs expConfigs)
  { 
    // Note: this is done so as to be backward compatible with Results
    if (!expConfigs.managedExecutionFolder)
      Results.initResultFolder(new File(".").getAbsolutePath());
    return new ExperimentResults(Results.getResultFolder());
  }

  private static ExperimentConfigs preloadExperimentsConfigs(Arguments arguments)
  {
    Creator c = Creators.conventional();
    try 
    {
      return c.init(ExperimentConfigs.class, arguments);
    }
    catch (Exception e) 
    {
      System.err.println(c.fullReport());
      return null;
    }
  }

}
