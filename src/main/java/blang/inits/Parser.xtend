package blang.inits


interface Parser<T> {
  def T parse(String inputs)
}