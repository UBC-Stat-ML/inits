package blang.input


interface Parser<T> {
  def T parse(String inputs)
}