import  engine_types

proc newPipelineStep*[T](): T =
  result = new(T)

proc beginFrame*[T](s: T, frame: RenderFrame) =
  discard frame