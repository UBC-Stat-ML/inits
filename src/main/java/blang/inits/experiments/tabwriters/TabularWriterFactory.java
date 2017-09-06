package blang.inits.experiments.tabwriters;

import blang.inits.Implementations;
import blang.inits.experiments.ExperimentResults;
import blang.inits.experiments.tabwriters.factories.CSV;
import blang.inits.experiments.tabwriters.factories.Spark;

@Implementations({CSV.class, Spark.class})
public interface TabularWriterFactory 
{
  /**
   * 
   * @param directory The containing directory context
   * @param name The name of the file to create (do not add .csv suffix).
   * @return
   */
  public TabularWriter build(ExperimentResults directory, String name);
}
