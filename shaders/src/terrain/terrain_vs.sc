$input a_position, a_texcoord0, a_normal, a_texcoord2, a_texcoord3, a_texcoord4
$output v_texcoord0, v_worldPos, v_materialID, v_normal, v_blendMode, v_adjacentMatIndices

#include "../common.sh"

void main()
{
	v_texcoord0 = a_texcoord0;
	v_worldPos = mul(u_model[0], vec4(a_position, 1.0) ).xyz;
	v_materialID = a_texcoord2;
	v_normal = normalize(mul(u_model[0], vec4(a_normal.xyz, 0.0) ).xyz);
	v_blendMode = a_texcoord3;
	v_adjacentMatIndices = a_texcoord4;
	
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0) );
}