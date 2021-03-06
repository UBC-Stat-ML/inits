package blang.inits

import java.lang.annotation.Retention
import java.lang.annotation.Target

@Retention(RUNTIME)
@Target(PARAMETER, FIELD)
annotation DefaultValue {
  val String[] value
}