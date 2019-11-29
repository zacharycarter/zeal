$input a_position, a_texcoord0, a_normal, a_texcoord2, a_texcoord3, a_texcoord4, a_texcoord5
$output v_texcoord0, v_worldPos, v_materialID, v_normal, v_blendMode, v_adjacentMatIndices

#include "../common.sh"

void main()
{
	v_texcoord0 = a_texcoord0;
	v_worldPos = mul(u_model[0], vec4(a_position, 1.0) ).xyz;
	v_materialID = a_texcoord2;
	v_normal = normalize(mul(u_model[0], vec4(a_normal.xyz, 0.0) ).xyz);
	v_blendMode = a_texcoord3;
	v_adjacentMatIndices = ivec4(
		(a_texcoord4.y << 16) | (a_texcoord4.x & 0xFFFF),
		(a_texcoord4.w << 16) | (a_texcoord4.z & 0xFFFF),
		(a_texcoord5.y << 16) | (a_texcoord5.x & 0xFFFF),
		(a_texcoord5.w << 16) | (a_texcoord5.z & 0xFFFF)
	);
	
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );
}