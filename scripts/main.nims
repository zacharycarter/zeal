import "dep.nims"

proc entry*() =
  setAmbientLightColor([1.0'f32, 1.0, 1.0])
  setEmitLightColor([1.0'f32, 1.0, 1.0])
  setEmitLightPos([1664.0'f32, 1024.0, 384.0])
  newGame("assets/maps", "foo.zmap")