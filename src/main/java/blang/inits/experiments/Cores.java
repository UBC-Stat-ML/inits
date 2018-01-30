package blang.inits.experiments;

import java.util.Optional;

import blang.inits.DesignatedConstructor;
import blang.inits.Input;
import blang.inits.providers.CoreProviders;

/**
 * Specifies either an explicit number of cores to use from a command line
 * argument, or the maximum number available if no argument is provided.
 */
public class Cores 
{
  public final int available;
  
  @DesignatedConstructor
  public Cores(
      @Input(formatDescription = "Integer - skip or "
          + "" + HALF + " to use half available; "
          + "" + MAX  + " to use max") Optional<String> input)
  {
    this(isFixed(input) ?
        CoreProviders.parse_int(input.get()) :
        resolveSpecial(input));
  }
  
  private static int resolveSpecial(Optional<String> input) 
  {
    int maxAvailable = Runtime.getRuntime().availableProcessors();
    if (!input.isPresent() || input.get().equals(HALF))
      return Math.max(1, maxAvailable / 2);
    if (input.get().equals(MAX))
      return maxAvailable;
    else
      throw new RuntimeException();
  }
  
  public Cores(int number) 
  {
    if (number < 1)
      throw new RuntimeException("Number of cores cannot be less than 1.");
    this.available = number;
  }
  
  public static Cores maxAvailable()
  {
    return new Cores(Optional.of(MAX));
  }
  
  public static Cores halfAvailable()
  {
    return new Cores(Optional.of(HALF));
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
    final String trimmed = input.get().trim();
    if (trimmed.equals(MAX) || trimmed.equals(HALF))
      return false;
    return true;
  }
  
  private static final String MAX = "MAX";
  private static final String HALF = "HALF";
}
