vec3 a_position                 : POSITION;
vec4 a_color0                   : COLOR0;
vec3 a_normal                   : NORMAL;
vec3 a_tangent                  : TANGENT;
vec2 a_texcoord0                : TEXCOORD0;

flat float a_texcoord2          : TEXCOORD2;
flat float a_texcoord3          : TEXCOORD3;
flat ivec4 a_texcoord4          : TEXCOORD4;
flat ivec4 a_texcoord5          : TEXCOORD5;

vec2 v_texcoord0                : TEXCOORD0 - vec2(0.0, 0.0);
vec3 v_worldPos                 : TEXCOORD1 = vec3(0.0, 0.0, 0.0);
flat float v_materialID         : TEXCOORD2 = 0.0;
vec3 v_normal                   : NORMAL    = vec3(0.0, 0.0, 0.0);
vec3 v_tangent                  : TANGENT   = vec3(0.0, 0.0, 0.0);
vec4 v_color0                   : COLOR0    = vec4(1.0, 0.0, 0.0, 1.0);
flat float v_blendMode          : TEXCOORD3 = 0.0;
flat ivec4 v_adjacentMatIndices : TEXCOORD4 = ivec4(0, 0, 0, 0);