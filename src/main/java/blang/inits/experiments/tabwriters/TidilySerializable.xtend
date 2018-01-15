package blang.inits.experiments.tabwriters

import blang.inits.experiments.tabwriters.TidySerializer.Context

interface TidilySerializable {
  def void serialize(Context context)
}