vec3 a_position                 : POSITION;
vec2 a_texcoord0                : TEXCOORD0;
vec3 a_normal                   : NORMAL;
flat float a_texcoord2          : TEXCOORD2;
flat float a_texcoord3          : TEXCOORD3;
flat ivec4 a_texcoord4          : TEXCOORD4;
flat ivec4 a_texcoord5          : TEXCOORD5;

vec2 v_texcoord0                : TEXCOORD0;
vec3 v_worldPos                 : TEXCOORD1;
flat int v_materialID           : TEXCOORD2;
vec3 v_normal                   : NORMAL;
flat int v_blendMode            : TEXCOORD3;
flat ivec4 v_adjacentMatIndices : TEXCOORD4;