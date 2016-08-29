package blang.inits

import org.junit.Test
import blang.inits.Arguments
import blang.inits.Posix
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
  
  var Creator c
  
  @Before
  def void before() {
    c = Creators.conventional()
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
    val List<Object> objects = #["some string", 17, 4.5, true, 23423L]
    for (Object o : objects) {
      println("Testing simple parser for type " + o.class)
      val String rep = o.toString()
      val Arguments arg = Posix.parse(rep)
      val Object result = c.init(o.class, arg)
      Assert.assertEquals(o, result)
    }
    TestSupport.assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(Boolean, Posix.parse("bad"))
    ]
    val Arguments maxArg = Posix.parse("INF") 
    Assert.assertEquals(c.init(Long, maxArg), Long.MAX_VALUE)
    Assert.assertEquals(c.<Double>init(Double, maxArg), Double.POSITIVE_INFINITY, 0.0)
    Assert.assertEquals(c.<Integer>init(Integer, maxArg), Integer.MAX_VALUE)   
  }
  
  @Test 
  def void testSimpleDeps() {
    Assert.assertEquals(
      c.init(Simple, Posix.parse(
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
    Assert.assertEquals(c.init(Level1, Posix.parse("--aLevel2.anInt", "123")).aLevel2.anInt, 123)
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
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadConstructor, Posix.parse())
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.MALFORMED_BUILDER].size)
    println(c.errorReport)
  }
  
  static class BadInput {
    @DesignatedConstructor
    new (@ConstructorArg("arg") int in) {
    }
  }
  
  @Test
  def void testBadInput() {
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, Posix.parse("--arg", "abc"))
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.FAILED_INSTANTIATION].size)
    println(c.errorReport)
  }
  
  @Test
  def void missingInput() {
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, Posix.parse())
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.MISSING_INPUT].size)
    println(c.errorReport)
  }
  
  @Test
  def void missingInput2() {
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, Posix.parse("--arg"))
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.FAILED_INSTANTIATION].size)
    println(c.errorReport)
  }
  
  @Test
  def void extraInput() {
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadInput, Posix.parse("--bad"))
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.UNKNOWN_INPUT].size)
    println(c.errorReport)
  }
  
  static class BadAnnotations {
    @DesignatedConstructor
    new(int test) {
    }
  }
  
  @Test
  def void badAnn() {
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(BadAnnotations, Posix.parse())
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.MALFORMED_ANNOTATION].size)
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
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(WithBadOptionals, Posix.parse())
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.MALFORMED_OPTIONAL].size)
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
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(WithBadOptionals2, Posix.parse())
    ]
    Assert.assertEquals(1,c.errors.entries.filter[it.value.category === InputExceptionCategory.MALFORMED_OPTIONAL].size)
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
    Assert.assertTrue(c.init(GoodOptionals, Posix.parse()) !== null)
  }
  
  @Test
  def void goodOpt2() {
    Assert.assertTrue(c.init(GoodOptionals, Posix.parse("--first", "234")) !== null)
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
    val TypeLiteral<Optional<MixedOptionals>> lit = new TypeLiteral<Optional<MixedOptionals>>() {}
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(lit, Posix.parse("--first", "123"))
    ]
    println(c.errorReport)
  } 
  
  @Test
  def void testMultipleErrors() {
    val TypeLiteral<Optional<MixedOptionals>> lit = new TypeLiteral<Optional<MixedOptionals>>() {}
    TestSupport::assertThrownExceptionMatches(InputExceptions.FAILED_INIT) [
      c.init(lit, Posix.parse(
        "--first", "abc"))
    ]
    println(c.errorReport)
  }
  
}