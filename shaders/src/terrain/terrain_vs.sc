$input a_position, a_texcoord0, a_normal, a_texcoord3, a_texcoord4, a_texcoord5
$output v_wpos, v_texcoord0, v_normal, v_materialID, v_blendMode, v_adjacentMatIndices

#include "../common.sh"

void main()
{
    v_texcoord0 = a_texcoord0;
    v_materialID = a_texcoord3;
    v_wpos = mul(u_model[0], vec4(a_position, 1.0)).xyz;
    v_normal = normalize(mul(u_model[0], vec4(a_normal, 0.0)).xyz);
    v_blendMode = a_texcoord4;
    v_adjacentMatIndices = a_texcoord5;

    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}
