package blang.inits.experiments;

import java.util.Optional;

import blang.inits.DesignatedConstructor;
import blang.inits.Input;

/**
 * Specifies either an explicit number of cores to use from a command line
 * argument, or the maximum number available if no argument is provided.
 */
public class Cores 
{
  public final int available;
  
  @DesignatedConstructor
  public Cores(@Input(formatDescription = "Integer - skip to use max available") Optional<String> input)
  {
    this(input.isPresent() ? 
        Integer.parseInt(input.get()) : 
        Runtime.getRuntime().availableProcessors()
        );
  }
  
  public Cores(int n) 
  {
    if (n < 1)
      throw new RuntimeException("Number of cores cannot be less than 1.");
    this.available = n;
  }
  
  public static Cores maxAvailable()
  {
    return new Cores(Optional.empty());
  }

  @Override
  public String toString() 
  {
    return "" + available + " cores";
  }
}
