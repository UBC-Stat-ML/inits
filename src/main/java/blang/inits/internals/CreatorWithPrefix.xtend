package blang.inits.internals

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate
import blang.inits.Creator
import blang.inits.parsing.QualifiedName
import com.google.inject.TypeLiteral
import blang.inits.parsing.Arguments

@Data
package class CreatorWithPrefix implements Creator {
  @Delegate
  val public CreatorImpl delegate
  
  val QualifiedName prefix
  
  def static CreatorWithPrefix build(CreatorImpl model, QualifiedName prefix)  {
    val CreatorImpl result = new CreatorImpl()
    result.globals.putAll(model.globals)
    result.factories.putAll(model.factories)
    return new CreatorWithPrefix(result, prefix)
  }
  
  override <T> T init(TypeLiteral<T> type, Arguments args) {
    return delegate.init(type, args.withQName(prefix))
  }
  
  override <T> T init(Class<T> type, Arguments args) {
    return delegate.init(type, args.withQName(prefix))
  }
}