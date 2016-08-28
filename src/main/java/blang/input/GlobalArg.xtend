package blang.input

import java.lang.annotation.Retention
import java.lang.annotation.Target

@Retention(RUNTIME)
@Target(FIELD, PARAMETER)
annotation GlobalArg {
  
}