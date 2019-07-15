import fpmath, render

const
  ENTITY_FLAG_ANIMATED* = (1 shl 0)
  ENTITY_FLAG_COLLISION* = (1 shl 1)
  ENTITY_FLAG_SELECTABLE* = (1 shl 2)
  ENTITY_FLAG_STATIC* = (1 shl 3)
  ENTITY_FLAG_COMBATABLE* = (1 shl 4)
  ENTITY_FLAG_INVISIBLE* = (1 shl 5)

type
  Entity* = object
    uid: uint32
    name: string
    basedir: string
    filename: string
    pos: Vec3
    scale: Vec3
    rotation: Quaternion
    flags: uint32
