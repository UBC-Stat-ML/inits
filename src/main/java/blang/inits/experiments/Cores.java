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
  public Cores(@Input(formatDescription = "Integer - skip or " + MAX + " to use max available") Optional<String> input)
  {
    this(isFixed(input) ? 
        Integer.parseInt(input.get()) : 
        Runtime.getRuntime().availableProcessors()
        );
  }
  
  public Cores(int number) 
  {
    if (number < 1)
      throw new RuntimeException("Number of cores cannot be less than 1.");
    this.available = number;
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
  
  private static boolean isFixed(Optional<String> input)
  {
    if (!input.isPresent())
      return false;
    if (input.get().trim().equals(MAX))
      return false;
    return true;
  }
  
  private static final String MAX = "MAX";
}
