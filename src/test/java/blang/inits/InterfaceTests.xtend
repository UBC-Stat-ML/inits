package blang.inits

import org.junit.Rule
import org.junit.rules.TestName
import org.junit.Before
import org.junit.After
import org.junit.Test
import blang.inits.Arg

import static blang.inits.Posix.parse
import org.junit.Assert
import blang.inits.InputExceptions.InputExceptionCategory

class InterfaceTests {
  
  Creator creator
  
  @Rule public TestName name = new TestName();
  
  @Before
  def void before() {
    println('''
    ###   «name.methodName»
    ''')
    creator = Creators.conventional()
  }
  
  @After
  def void after() {
    println()
    println()
  }
  
  static class TestInterface {
    
    @Arg Number n
  }
  
  @Test
  def void testLoadGoodInterface() {
    println(creator.init(TestInterface, parse("--n", "java.lang.Double", "14.5")).n)
  }
  
  @Test
  def void testBadInterface1() {
    assertThrows[ creator.init(TestInterface, parse("java.lang.Double", "14.5")) ]
    Assert.assertEquals(1,creator.errors.filter[it.value.category === InputExceptionCategory.MISSING_INPUT].size)
    println(creator.errorReport)
  }
  
  @Test
  def void testBadInterface2() {
    assertThrows[ creator.init(TestInterface, parse("--n", "java.lang.Bad", "14.5")) ]
    Assert.assertEquals(1,creator.errors.filter[it.value.category === InputExceptionCategory.MALFORMED_INTERFACE_IMPLEMENTATION].size)
    println(creator.errorReport)
  }
  
  @Test
  def void testBadInterface3() {
    assertThrows[ creator.init(TestInterface, parse("--n", "java.lang.String", "14.5")) ]
    Assert.assertEquals(1,creator.errors.filter[it.value.category === InputExceptionCategory.MALFORMED_INTERFACE_IMPLEMENTATION].size)
    println(creator.errorReport)
  }
  
  @Test
  def void testBadInterface4() {
    assertThrows[ creator.init(TestInterface, parse("--n", "java.lang.Double")) ]
    Assert.assertEquals(1,creator.errors.filter[it.value.category === InputExceptionCategory.FAILED_INSTANTIATION].size)
    println(creator.errorReport)
  }
  
  def static void assertThrows(Runnable runnable) {
    TestSupport::assertThrownExceptionMatches(InputExceptions::FAILED_INIT, runnable)
  }
}