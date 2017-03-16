package blang.inits;

public class ImplTest implements Runnable
{
  @Arg SomeInterface interf;
  
  public void run() 
  {
    System.out.println(interf);
  }
  
  public static void main(String [] args) 
  {
    Inits.parseAndRun(ImplTest.class, args);
  }
}
