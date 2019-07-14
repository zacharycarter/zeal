$input a_position, a_texcoord0, a_normal, i_data0, i_data1
$output v_texcoord0, v_materialID, v_wpos, v_normal, v_blendMode, v_adjacentMatIndices

#include "../common.sh"

void main()
{
    v_texcoord0 = a_texcoord0;
    v_materialID = a_normal[3];
    v_wpos = mul(u_model[0], vec4(a_position, 1.0)).xyz;
    v_normal = normalize(mul(u_model[0], vec4(a_normal.xyz, 0.0) ).xyz);
    v_blendMode = i_data0;
    v_adjacentMatIndices = i_data1;

    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}
