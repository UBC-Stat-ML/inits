package blang.input

import org.junit.Test
import blang.inits.Arguments
import blang.inits.PosixParser
import java.util.List
import org.junit.Assert
import org.eclipse.xtend.lib.annotations.Data
import blang.inits.ConstructorArg
import java.util.ArrayList
import blang.inits.DesignatedConstructor

class BasicTests {
  
  
  @Test
  def void testBasicParser() {
    
    println("Basic parser")
    
    val Creator c = Creator.conventionalCreator

    val List<Object> objects = #["some string", 17, 4.5, true, 23423L]
    for (Object o : objects) {
      println("Testing simple parser for type " + o.class)
      val String rep = o.toString()
      val Arguments arg = PosixParser.parse(rep)
      val Object result = c.init(o.class, arg)
      Assert.assertEquals(o, result)
    }
    
    TestSupport.assertThrownExceptionMatches(Creator.FAILED_INIT) [
      c.init(Boolean, PosixParser.parse("bad"))
    ]
    
    val Arguments maxArg = PosixParser.parse(ConventionalParsers.INF_STR) 
    Assert.assertEquals(c.init(Long, maxArg), Long.MAX_VALUE)
    Assert.assertEquals(c.<Double>init(Double, maxArg), Double.POSITIVE_INFINITY, 0.0)
    Assert.assertEquals(c.<Integer>init(Integer, maxArg), Integer.MAX_VALUE)   
    
  }
  
  @Test 
  def void testSimpleDeps() {
    
    println("Simple deps")
    
    val Creator c = Creator.conventionalCreator
    
    Assert.assertEquals(
      c.init(Simple, PosixParser.parse(
        "--a", "1",
        "--b", "-2",
        "--c", "true",
        "--d", "false",
        "--e", "234",
        "--f", "-23423",
        "--g", "-234e13",
        "--h", "INF")).stuff.toString(), 
      "[1, -2, true, false, 234, -23423, -2.34E15, Infinity]")
      
    println(c.usage)
  }
  
  // TODO: check missing @Desig..
  // TODO: check reporting of parsing errors
  // TODO: additional/bad/missing args
  
  @Data
  static class Simple {
    val List<Object> stuff
    
    @DesignatedConstructor
    def static Simple build(
      @ConstructorArg("a") int a,
      @ConstructorArg("b") Integer b,
      @ConstructorArg("c") boolean c,
      @ConstructorArg("d") Boolean d,
      @ConstructorArg("e") Long e,
      @ConstructorArg("f") long f,
      @ConstructorArg("g") Double g,
      @ConstructorArg("h") double h
    ) {
      val List<Object> stuff = new ArrayList
      stuff => [
        add(a)
        add(b)
        add(c)
        add(d)
        add(e)
        add(f)
        add(g)
        add(h)
      ]
      return new Simple(stuff)
    }
  }
  
  @Test
  def void testDeeperDeps() {
    
    println("Deep deps")
    
    val Creator c = Creator.conventionalCreator
    Assert.assertEquals(c.init(Level1, PosixParser.parse("--aLevel2.anInt", "123")).aLevel2.anInt, 123)
    
    println(c.usage())
  }
  
  static class Level1 {
    val Level2 aLevel2
    @DesignatedConstructor
    new (@ConstructorArg("aLevel2") Level2 level2) {
      this.aLevel2 = level2
    }
  }
  
  static class Level2 {
    val int anInt
    @DesignatedConstructor
    new (@ConstructorArg(value = "anInt", description = "An int!") int anInt) {
      this.anInt = anInt
    }
  }
  
}