foreign class Vec3 {
    construct create(x, y, z) {}
    foreign x
    foreign y
    foreign z
}

foreign class Game {
    foreign static new(mapDir, mapName)
    foreign static setAmbientLightColor(color)
    foreign static setEmitLightColor(color)
    foreign static setEmitLightPos(pos)
}

foreign class Window {
    construct create() {}
}