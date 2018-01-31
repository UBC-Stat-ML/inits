package blang.inits.experiments;

import java.lang.management.ManagementFactory;
import java.lang.management.OperatingSystemMXBean;
import java.lang.reflect.Method;

import blang.inits.Arg;
import blang.inits.DefaultValue;
import blang.inits.Implementations;
import briefj.BriefLog;

/**
 * Specifies either an explicit number of cores to use, or dynamically 
 * by picking a fraction of 
 * the number of cores available (optionally, taking out those being 
 * utilized).
 */
@Implementations({Cores.Dynamic.class, Cores.Fixed.class})
public interface Cores 
{
  public int numberAvailable();
  
  public static Cores max() 
  {
    return new Dynamic(1.0, false);
  }
  
  public static Cores allUnutilized()
  {
    return new Dynamic(1.0, true);
  }
  
  public static Cores dynamic()
  {
    return halfUnutilized();
  }
  
  public static Cores halfUnutilized()
  {
    return new Dynamic(0.5, true);
  }
  
  public static Cores fixed(int n) 
  {
    return new Fixed(n);
  }
  
  public static Cores single()
  {
    return fixed(1);
  }
  
  public static class Dynamic implements Cores
  {
    @Arg      @DefaultValue("0.5")
    public double fraction = 0.5;
    
    @Arg                  @DefaultValue("true")
    public boolean ignoreUtilizedCores = true;
    
    @Arg      @DefaultValue("false")
    public boolean verbose = false;
    
    public Dynamic() {}
    
    public Dynamic(double fraction, boolean ignoreUtilizedCores) {
      this.fraction = fraction;
      this.ignoreUtilizedCores = ignoreUtilizedCores;
    }

    @Override
    public int numberAvailable() 
    {
      double nCores = Runtime.getRuntime().availableProcessors();
      if (ignoreUtilizedCores)
        nCores = ignoreUtilizedCores(nCores);
      int result = Math.max(1, (int) (fraction * nCores));
      if (verbose)
        System.out.println("Allocated " + result + " cores");
      return result;
    }

    private double ignoreUtilizedCores(double nCores) 
    {
      try 
      {
        double systemLoad = getLoadStatistic("getSystemCpuLoad");
        double currentProcessLoad = getLoadStatistic("getProcessCpuLoad");
        double outsideLoad = systemLoad - currentProcessLoad;
        if (outsideLoad < 0.0)
        {
          BriefLog.warnOnce("Bad estimation of system load. Backing off to all cores available");
          return nCores;
        }
        return (1.0 - outsideLoad) * nCores;
      }
      catch (Exception e)
      {
        return nCores;
      }
    }
    
    // Based on: https://stackoverflow.com/questions/47177/how-do-i-monitor-the-computers-cpu-memory-and-disk-usage-in-java?rq=1
    private double getLoadStatistic(String methodName) 
    {
      OperatingSystemMXBean operatingSystemMXBean = ManagementFactory.getOperatingSystemMXBean();
      final String COULD_NOT_ESTIMATE_SYSTEM_CPU_USAGE = 
          "could not estimate system CPU load (available on Oracle JVM only) - "
              + "ignoring other processes for dynamic allocation of the number of cores";
      for (Method method : operatingSystemMXBean.getClass().getDeclaredMethods()) 
      {
        method.setAccessible(true);
        if (method.getName().equals(methodName)) 
        {
          try {
            return (double) method.invoke(operatingSystemMXBean);
          } 
          catch (Exception e) 
          {
            BriefLog.warnOnce(COULD_NOT_ESTIMATE_SYSTEM_CPU_USAGE);
            throw new RuntimeException();
          } 
        } 
      }
      BriefLog.warnOnce(COULD_NOT_ESTIMATE_SYSTEM_CPU_USAGE);
      throw new RuntimeException();
    }
  }
  
  public static class Fixed implements Cores
  {
    @Arg @DefaultValue("1")
    public int number = 1;

    public Fixed() {}
    
    public Fixed(int number) 
    {
      this.number = number;
    }

    @Override
    public int numberAvailable() 
    {
      return number;
    }
  }
}
