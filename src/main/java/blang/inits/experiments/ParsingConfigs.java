package blang.inits.experiments;

import blang.inits.Creator;
import blang.inits.Creators;

public class ParsingConfigs
{
  Creator creator = Creators.conventional();
  
  // If null, automatically infered from the class from which the main is called
  private Class<? extends Experiment> experimentClass = null;
  
  public void setCreator(Creator creator)
  {
    this.creator = creator;
  }

  public void setExperimentClass(Class<? extends Experiment> experimentClass)
  {
    this.experimentClass = experimentClass;
  }

  @SuppressWarnings("unchecked")
  public Class<? extends Experiment> findExperimentClass()
  {
    if (experimentClass != null)
      return experimentClass;
    try
    {
      StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
      String className = stackTrace[stackTrace.length - 1].getClassName();
      return (Class<? extends Experiment>) Class.forName(className);
    } 
    catch (ClassNotFoundException e)
    {
      throw new RuntimeException(e);
    }
  }
}