vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec3 a_normal    : NORMAL;
int a_texcoord3  : TEXCOORD3;
int a_texcoord4 : TEXCOORD4;
ivec4 a_texcoord5 : TEXCOORD5;


vec3 v_wpos : TEXCOORD2;
vec2 v_texcoord0 : TEXCOORD0;
vec3 v_normal : NORMAL;
flat int v_materialID : TEXCOORD3;
flat int v_blendMode : TEXCOORD4;
flat ivec4 v_adjacentMatIndices : TEXCOORD5;