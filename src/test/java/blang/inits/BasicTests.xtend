package blang.inits

import org.junit.Test
import blang.inits.Arguments
import blang.inits.PosixParser
import java.util.List
import org.junit.Assert
import org.eclipse.xtend.lib.annotations.Data
import blang.inits.ConstructorArg
import java.util.ArrayList
import blang.inits.DesignatedConstructor
import blang.inits.InputExceptions
import blang.inits.InputExceptions.InputExceptionCategory
import org.junit.Rule
import org.junit.rules.TestName
import org.junit.Before
import org.junit.After
import java.util.Optional
import com.google.common.reflect.TypeToken
import com.google.inject.TypeLiteral

class BasicTests {
  
  @Rule public TestName name = new TestName();
  
  @Before
  def void before() {
    println('''
    ###   «name.methodName»
    ''')
  }
  
  @After
  def void after() {
    println()
    println()
  }
  
  @Test
  def void testBasicParser() {
    val Creator c = Creator.conventionalCreator
    val List<Object> objects = #["some string", 17, 4.5, true, 23423L]
    for (Object o : objects) {
      println("Testing simple parser for type " + o.class)
      val String rep = o.toString()
      val Arguments arg = PosixParser.parse(rep)
      val Object result = c.init(o.class, arg)
      Assert.assertEquals(o, result)
    }
    TestSupport.assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(Boolean, PosixParser.parse("bad"))
    ]
    val Arguments maxArg = PosixParser.parse("INF") 
    Assert.assertEquals(c.init(Long, maxArg), Long.MAX_VALUE)
    Assert.assertEquals(c.<Double>init(Double, maxArg), Double.POSITIVE_INFINITY, 0.0)
    Assert.assertEquals(c.<Integer>init(Integer, maxArg), Integer.MAX_VALUE)   
  }
  
  @Test 
  def void testSimpleDeps() {
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
  
  static class BadConstructor {
    new (int test) {
    }
  }
  
  @Test
  def void testExceptions() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadConstructor, PosixParser.parse())
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.MALFORMED_BUILDER].size)
    println(c.errorReport)
  }
  
  static class BadInput {
    @DesignatedConstructor
    new (@ConstructorArg("arg") int in) {
    }
  }
  
  @Test
  def void testBadInput() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, PosixParser.parse("--arg", "abc"))
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.FAILED_INSTANTIATION].size)
    println(c.errorReport)
  }
  
  @Test
  def void missingInput() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, PosixParser.parse())
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.MISSING_INPUT].size)
    println(c.errorReport)
  }
  
  @Test
  def void missingInput2() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, PosixParser.parse("--arg"))
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.FAILED_INSTANTIATION].size)
    println(c.errorReport)
  }
  
  @Test
  def void extraInput() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, PosixParser.parse("--bad"))
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.UNKNOWN_INPUT].size)
    println(c.errorReport)
  }
  
  static class BadAnnotations {
    @DesignatedConstructor
    new(int test) {
    }
  }
  
  @Test
  def void badAnn() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadAnnotations, PosixParser.parse())
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.MALFORMED_ANNOTATION].size)
    println(c.errorReport)
  }
  
  static class WithBadOptionals {
    @DesignatedConstructor
    def static WithBadOptionals build(
      @ConstructorArg("first") com.google.common.base.Optional<Integer> badOpt) {
    }
  }
  
  @Test
  def void badOpt() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(WithBadOptionals, PosixParser.parse())
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.MALFORMED_OPTIONAL].size)
    println(c.errorReport)
  }
  
  static class WithBadOptionals2 {
    @DesignatedConstructor
    def static WithBadOptionals build(
      @ConstructorArg("first") Optional badOpt) {
    }
  }
  
  @Test
  def void badOpt2() {
    val Creator c = Creator.conventionalCreator
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(WithBadOptionals2, PosixParser.parse())
    ]
    Assert.assertEquals(1,c.errors.filter[it.value.category === InputExceptionCategory.MALFORMED_OPTIONAL].size)
    println(c.errorReport)
  }
  
  static class GoodOptionals {
    @DesignatedConstructor
    def static GoodOptionals build(
      @ConstructorArg("first")  Optional<Integer> first,
      @ConstructorArg("second") Optional<Integer> second) {
      new GoodOptionals
    }
  }
  
  @Test
  def void goodOpt() {
    val Creator c = Creator.conventionalCreator
    Assert.assertTrue(c.init(GoodOptionals, PosixParser.parse()) !== null)
  }
  
  @Test
  def void goodOpt2() {
    val Creator c = Creator.conventionalCreator
    Assert.assertTrue(c.init(GoodOptionals, PosixParser.parse("--first", "234")) !== null)
  }
  
  static class MixedOptionals {
    @DesignatedConstructor
    def static GoodOptionals build(
      @ConstructorArg("first")  Optional<Integer> first,
      @ConstructorArg("second") int second) {
      new GoodOptionals
    }
  }
  
  @Test
  def void mixedOptional() {
    val Creator c = Creator.conventionalCreator
    val TypeLiteral<Optional<MixedOptionals>> lit = new TypeLiteral<Optional<MixedOptionals>>() {}
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(lit, PosixParser.parse("--first", "123"))
    ]
    println(c.errorReport)
  } 
  
  @Test
  def void testMultipleErrors() {
    val Creator c = Creator.conventionalCreator
    val TypeLiteral<Optional<MixedOptionals>> lit = new TypeLiteral<Optional<MixedOptionals>>() {}
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(lit, PosixParser.parse(
        "--first", "abc"))
    ]
    println(c.errorReport)
  }
  
}