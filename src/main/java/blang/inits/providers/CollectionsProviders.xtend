package blang.inits.providers

import blang.inits.ProvidesFactory
import blang.inits.Input
import java.util.List
import blang.inits.InitService
import com.google.inject.TypeLiteral
import blang.inits.Creator
import java.util.ArrayList
import java.lang.reflect.ParameterizedType
import blang.inits.parsing.SimpleParser

class CollectionsProviders {
  
  @ProvidesFactory
  def static <T> List<T> parseList(
    @Input       List<String>         strings,
    @InitService TypeLiteral<List<T>> actualType,
    @InitService Creator              creator
  ) {
    val TypeLiteral<T> typeArgument = 
      TypeLiteral.get((actualType.type as ParameterizedType).actualTypeArguments.get(0))
      as TypeLiteral<T>
    val List<T> result = new ArrayList
    for (String string : strings) {
      result.add(creator.init(typeArgument, SimpleParser.parse(string)))
    }
    return result
  }
  
}