import bgfxdotnim, fpmath, texture

type
  Material* = object
    ambientIntensity: float32
    diffuseColor: Vec3
    specularColor: Vec3
    texture: Texture
    textureName: string