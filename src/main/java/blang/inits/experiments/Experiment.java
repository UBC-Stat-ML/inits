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
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.lang3.exception.ExceptionUtils;

import com.google.common.base.Joiner;
import com.google.common.hash.HashCode;

import blang.inits.Arg;
import blang.inits.Creator;
import blang.inits.Creators;
import blang.inits.GlobalArg;
import blang.inits.Inits;
import blang.inits.parsing.Arguments;
import blang.inits.parsing.Arguments.ArgumentItem;
import blang.inits.parsing.CSVFile;
import blang.inits.parsing.Posix;
import blang.inits.parsing.QualifiedName;
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
  public ExperimentResults results = new ExperimentResults();
  
  public static int start(
      String [] args)
  {
    return start(args, new ParsingConfigs());
  }
  
  public static void startAutoExit(String [] args)
  {
    System.exit(start(args));
  }
  
  public static final int SUCCESS_CODE = 0;
  public static final int BAD_EXP_CONFIG_CODE = 1;
  public static final int CLI_PARSING_ERROR_CODE = 2;
  public static final int EXCEPTION_CODE = 3;
  
  public static final String PARSING_ERROR_FILE = "parsing-errors.txt";

  public static int start(
      String [] args,
      ParsingConfigs configs)
  {
    return start(args, Posix.parse(args), configs);
  }
  
  public static int start(
      String [] rawArgs,
      Arguments parsedArgs,
      ParsingConfigs configs)
  {
    ExperimentConfigs expConfigs = preloadExperimentsConfigs(parsedArgs.child(EXP_CONFIG_FIELD_NAME));
    if (expConfigs == null)
      return BAD_EXP_CONFIG_CODE;
    
    ExperimentResults results = createExperimentResultsObject(expConfigs);
    configs.creator.addGlobal(ExperimentResults.class, results);
    
    if (expConfigs.configFile.isPresent())
      parsedArgs = addConfigFileArguments(parsedArgs, CSVFile.parseTSV(expConfigs.configFile.get()));
    
    Runnable experiment = null;
    try 
    {
      experiment = configs.creator.init(configs.findExperimentClass(), parsedArgs);
    } 
    catch (Exception e) 
    {
      if (parsedArgs.childrenKeys().contains(Inits.HELP_STRING)) 
      {
        cleanEmptyResultFolder(results, expConfigs);
        System.out.println(configs.creator.usage());
        return SUCCESS_CODE;
      }
      else
      {
        write(
            getFile(PARSING_ERROR_FILE),
            configs.creator.fullReport());
        System.err.println(configs.creator.fullReport());
        return CLI_PARSING_ERROR_CODE;
      }
    }
    
    // report command line options and some more
    Tees tees = !exists(STD_OUT_FILE) && expConfigs.saveStandardStreams ?
        RedirectionUtils.createTees(getExecutionInfoFolder()) :
        null;
    
    if (expConfigs.recordExecutionInfo) 
    {
      recordArguments(configs.creator, results);
      recordExecutionInfo(experiment, rawArgs);
    }
    
    long startTime = System.currentTimeMillis();
    
    if (expConfigs.recordExecutionInfo)
      write(
          getFile(START_TIME_FILE),
          "" + startTime);
    
    boolean success = true;
    try 
    {
      experiment.run();
    }
    catch (Exception e)
    {
      String errorMessage = ExceptionUtils.getStackTrace(e);
      write(getFile(EXCEPTION_FILE), errorMessage);
      System.err.println(errorMessage);
      success = false;
    }
    finally
    {
      long endTime = System.currentTimeMillis();
      
      if (expConfigs.recordExecutionInfo)
        write(
            getFile(END_TIME_FILE),
            "" + endTime);
      
      if (tees != null)
        tees.close();
      
      // close all streams
      results.closeAll();
      
      System.out.println("executionMilliseconds : " + (endTime - startTime));
      System.out.println("outputFolder : " + Results.getResultFolder().getAbsolutePath());
    }
    return success ? SUCCESS_CODE : EXCEPTION_CODE;
  }
  
  private static Arguments addConfigFileArguments(Arguments fromCLI, Arguments fromConfig)
  {
    LinkedHashMap<QualifiedName, List<String>> 
      cliMap  = fromCLI.asMap(),
      confMap = fromConfig.asMap();
    
    for (QualifiedName name : confMap.keySet())
      if (!cliMap.containsKey(name))
        cliMap.put(name, confMap.get(name));
    
    List<ArgumentItem> items = new ArrayList<Arguments.ArgumentItem>();
    for (QualifiedName name : cliMap.keySet())
      items.add(new ArgumentItem(name.getPath(), cliMap.get(name)));
    
    return Arguments.parse(items);
  } 

  public static final String CSV_ARGUMENT_FILE = "arguments.tsv";
  public static final String DETAILED_ARGUMENT_FILE = "arguments-details.txt";
  
  private static void recordArguments(Creator creator, ExperimentResults results)
  {
    BriefIO.write(results.getFileInResultFolder(CSV_ARGUMENT_FILE), 
        creator
          .asMap()
          .entrySet()
          .stream()
          .map(e -> e.getKey() + "\t" + e.getValue())
          .collect(Collectors.joining("\n")));
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
    
    /*
     * TODO: this could be improved to allow creating 'sub-experiments'?
     * Would involve checking first if Results is already initialized (may require updating briefj)
     * DANGER: this will lead to undesirable situations in backward compatibility mode, just think 
     * of the current way the run parameters are saved, which uses the backward compatibility mode.
     *   Would need to get rid of backward compatibility first probably, at very least for the 
     *   context stuff. 
     * 
     * In some cases, e.g. loading parts of options e.g. for a saved model etc, make use of Inits.* 
     * methods instead. 
     */
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
