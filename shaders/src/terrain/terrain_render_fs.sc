$input v_texcoord0

#include "../terrain_common.sh"

SAMPLER2D(u_SplatMapSampler, 9);
SAMPLER2D(u_GrassSampler, 10);
SAMPLER2D(u_CliffsSampler, 11);
SAMPLER2D(u_SnowyGrassSampler, 12);

void main()
{
	// vec2 s = texture2D(u_SmapSampler, v_texcoord0).rg * u_DmapFactor;
	// vec3 n = normalize(vec3(-s, 1));
	// float d = clamp(n.z, 0.0, 1.0) / 3.14159;
	// vec3 r = vec3(d, d, d);
	// gl_FragColor = vec4(r, 1);

	vec4 alpha   = texture2D( u_SplatMapSampler, v_texcoord0.xy );
	vec4 tex0    = texture2D( u_SnowyGrassSampler, v_texcoord0.xy * 8.0 ); // Tile
	vec4 tex1    = texture2D( u_CliffsSampler,  v_texcoord0.xy * 8.0 ); // Tile
	vec4 tex2    = texture2D( u_GrassSampler, v_texcoord0.xy * 8.0 ); // Tile

	tex0 *= alpha.r; // Red channel
	tex1 = mix( tex0, tex1, alpha.g ); // Green channel
	vec4 outColor = mix( tex1, tex2, alpha.b ); // Blue channel
	
	gl_FragColor = outColor;
}