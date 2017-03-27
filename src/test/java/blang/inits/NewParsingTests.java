package blang.inits;

import org.junit.Assert;
import org.junit.Test;

import blang.inits.providers.CoreProviders;

public class NewParsingTests
{
  @Test
  public void test()
  {
    Assert.assertEquals(10_000, CoreProviders.parse_int("10_000"));
    Assert.assertEquals(10_000L, CoreProviders.parse_long("10_000"));
    Assert.assertEquals(10_000.0, CoreProviders.parse_double("10_000.0"), 0.0);
  }
}
