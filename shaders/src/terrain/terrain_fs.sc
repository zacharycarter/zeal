$input v_texcoord0, v_worldPos, v_materialID, v_normal, v_blendMode, v_adjacentMatIndices

#include "../common.sh"

#define SPECULAR_STRENGTH  0.5
#define SPECULAR_SHININESS 2

#define Y_COORDS_PER_TILE  4 
#define EXTRA_AMBIENT_PER_LEVEL 0.03

#define BLEND_MODE_NOBLEND  0
#define BLEND_MODE_BLUR     1

#define TERRAIN_AMBIENT     float(0.7)
#define TERRAIN_DIFFUSE     vec3(0.9, 0.9, 0.9)
#define TERRAIN_SPECULAR    vec3(0.1, 0.1, 0.1)

uniform vec4 ambient_color;
uniform vec4 light_color;
uniform vec4 light_pos;
uniform vec4 view_pos;

SAMPLER2DARRAY(s_texColor, 0);

vec4 texture_val(int mat_idx, vec2 uv)
{
    return texture2DArray(s_texColor, vec3(uv, (float)mat_idx));
}

vec4 mixed_texture_val(int adjacency_mats, vec2 uv)
{
    vec4 ret = vec4(0.0f, 0.0f, 0.0f, 0.0f);
    for(int i = 0; i < 8; i++) {
        int idx = (adjacency_mats >> (i * 4)) & 0xf;
        ret += texture_val(idx, uv) * (1.0/8.0);
    }
    return ret;
}

vec4 bilinear_interp_vec4
(
    vec4 q11, vec4 q12, vec4 q21, vec4 q22, 
    float x1, float x2, 
    float y1, float y2, 
    float x, float y
)
{
    float x2x1, y2y1, x2x, y2y, yy1, xx1;

    x2x1 = x2 - x1;
    y2y1 = y2 - y1;
    x2x = x2 - x;
    y2y = y2 - y;
    yy1 = y - y1;
    xx1 = x - x1;

    return 1.0 / (x2x1 * y2y1) * (
        q11 * x2x * y2y +
        q21 * xx1 * y2y +
        q12 * x2x * yy1 +
        q22 * xx1 * yy1
    );
}

void main() 
{
    vec4 tex_color;

    switch(v_blendMode)
    {
        case BLEND_MODE_NOBLEND: 
            tex_color = texture_val(v_materialID, v_texcoord0);
            break;
        case BLEND_MODE_BLUR:
            /* 
            * This shader will blend this tile's texture(s) with adjacent tiles' textures 
            * based on adjacency information of neighboring tiles' materials.
            *
            * Our top tile faces are made up of 4 triangles in the following configuration:
            * (Note that the 4 "major" triangles may be further subdivided. In that case, the 
            * triangles it is subdivided to must inherit the flat adjacency attributes. The
            * other attributes will be interpolated. This is a detail not discussed further on.)
            *
            *  +----+----+
            *  | \ top / |
            *  |  \   /  |
            *  + l -+- r +
            *  |  /   \  |
            *  | / bot \ |
            *  +----+----+
            *
            * Each of the 4 triangles has a vertex at the center of the tile. The 'adjacent_mat_indices'
            * is a 'flat' attribute, so it will be the same for all fragments of a triangle.
            *
            * The UV coordinates for a tile go from (0.0, 1.0) to (1.0, 1.0) in the diagonal corner so
            * we are able to determine which of the 4 triangles this fragment is in by checking 
            * the interpolated UV coordinate.
            *
            * For a single tile, there are 9 reference points on the face of the tile: The 4 corners
            * of the tile, the midpoints of the 4 edges, and the center point.
            *
            *  +---+---+
            *  | 1 | 2 |
            *  +---+---+
            *  | 4 | 3 |
            *  +---+---+ 
            *
            * Based on which quadrant we're in (which can be determined from UV), we will select the closest 
            * 4 points and use bilinear interpolation to select the texture color for this fragment using 
            * the UV coordinate.
            *
            * The first two elements of 'adjacent_mat_indices' hold the adjacency information for the 
            * two non-center vertices for this triangle. Each element has 8 4-bit indices packed into the 
            * least significant 32 bits, resulting in 8 indices for each of the two vertices. Each index
            * is the material of one of the 8 triangles touching the vertex.
            *
            * The next element of 'adjacent_mat_indices' holds the materials for the centers of the 
            * edges of the tile, with 2 4-bit indices for each edge.
            * 
            * The last element of 'adjacent_mat_indices' holds the 2 materials at the central point of 
            * the tile in the lowest 8 bits. Usually the 2 indices are the same except for some corner tiles
            * where half of the tile uses a different material.
            *
            */
            bool bot   = (v_texcoord0.x > v_texcoord0.y) && (1.0 - v_texcoord0.x > v_texcoord0.y);
            bool top   = (v_texcoord0.x < v_texcoord0.y) && (1.0 - v_texcoord0.x < v_texcoord0.y);
            bool left  = (v_texcoord0.x < v_texcoord0.y) && (1.0 - v_texcoord0.x > v_texcoord0.y);
            bool right = (v_texcoord0.x > v_texcoord0.y) && (1.0 - v_texcoord0.x < v_texcoord0.y);

            bool left_half = v_texcoord0.x < 0.5f;
            bool bot_half = v_texcoord0.y < 0.5f;

            /***********************************************************************
            * Set the fragment texture color
            **********************************************************************/
            vec4 color1 = mixed_texture_val(v_adjacentMatIndices.x, v_texcoord0);
            vec4 color2 = mixed_texture_val(v_adjacentMatIndices.y, v_texcoord0);

            vec4 tile_color = mix(
                texture_val((v_adjacentMatIndices.w >> 0) & 0xf, v_texcoord0), 
                texture_val((v_adjacentMatIndices.w >> 4) & 0xf, v_texcoord0), 
                0.5f
            );
            vec4 left_center_color =  mix(
                texture_val((v_adjacentMatIndices.z >> 0) & 0xf, v_texcoord0), 
                texture_val((v_adjacentMatIndices.z >> 4) & 0xf, v_texcoord0), 
                0.5f
            );
            vec4 bot_center_color = mix(
                texture_val((v_adjacentMatIndices.z >> 8) & 0xf, v_texcoord0),
                texture_val((v_adjacentMatIndices.z >> 12) & 0xf, v_texcoord0),
                0.5f
            );
            vec4 right_center_color = mix(
                texture_val((v_adjacentMatIndices.z >> 16) & 0xf, v_texcoord0), 
                texture_val((v_adjacentMatIndices.z >> 20) & 0xf, v_texcoord0), 
                0.5f
            );
            vec4 top_center_color = mix(
                texture_val((v_adjacentMatIndices.z >> 24) & 0xf, v_texcoord0), 
                texture_val((v_adjacentMatIndices.z >> 28) & 0xf, v_texcoord0), 
                0.5f
            );

            if (top)
            {
                if (left_half)
                    tex_color = bilinear_interp_vec4(left_center_color, color1, tile_color, top_center_color,
                        0.0f, 0.5f, 0.5f, 1.0f, v_texcoord0.x, v_texcoord0.y);        
                else
                    tex_color = bilinear_interp_vec4(tile_color, top_center_color, right_center_color, color2,
                        0.5f, 1.0f, 0.5f, 1.0f, v_texcoord0.x, v_texcoord0.y);
            }
            else if (bot)
            {
                if (left_half)
                    tex_color = bilinear_interp_vec4(color1, left_center_color, bot_center_color, tile_color,
                        0.0f, 0.5f, 0.0f, 0.5f, v_texcoord0.x, v_texcoord0.y);        
                else
                    tex_color = bilinear_interp_vec4(bot_center_color, tile_color, color2, right_center_color,
                        0.5f, 1.0f, 0.0f, 0.5f, v_texcoord0.x, v_texcoord0.y);
            }
            else if (left)
            {
                if (bot_half)
                    tex_color = bilinear_interp_vec4(color1, left_center_color, bot_center_color, tile_color,
                        0.0f, 0.5f, 0.0f, 0.5f, v_texcoord0.x, v_texcoord0.y);        
                else
                    tex_color = bilinear_interp_vec4(left_center_color, color2, tile_color, top_center_color,
                        0.0f, 0.5f, 0.5f, 1.0f, v_texcoord0.x, v_texcoord0.y);
            }
            else if (right)
            {
                if (bot_half)
                    tex_color = bilinear_interp_vec4(bot_center_color, tile_color, color1, right_center_color,
                        0.5f, 1.0f, 0.0f, 0.5f, v_texcoord0.x, v_texcoord0.y);        
                else
                    tex_color = bilinear_interp_vec4(tile_color, top_center_color, right_center_color, color2,
                        0.5f, 1.0f, 0.5f, 1.0f, v_texcoord0.x, v_texcoord0.y);
            }

            break;
        default:
            tex_color = vec4(1.0, 0.0, 1.0, 1.0);
            return;
    }
    
    /* Simple alpha test to reject transparent pixels */
    if (tex_color.a == 0.0)
        discard;

    /* We increase the amount of ambient light that taller tiles get, in order to make
     * them not blend with lower terrain. */
    float height = v_worldPos.y / Y_COORDS_PER_TILE;

    /* Ambient calculations */
    vec3 ambient = (TERRAIN_AMBIENT + height * EXTRA_AMBIENT_PER_LEVEL) * ambient_color;

    /* Diffuse calculations */
    vec3 light_dir = normalize(light_pos - v_worldPos);  
    float diff = max(dot(v_normal, light_dir), 0.0);
    vec3 diffuse = light_color * (diff * TERRAIN_DIFFUSE);

    /* Specular calculations */
    vec3 view_dir = normalize(view_pos - v_worldPos);
    vec3 reflect_dir = reflect(-light_dir, v_normal);  
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), SPECULAR_SHININESS);
    vec3 specular = SPECULAR_STRENGTH * light_color * (spec * TERRAIN_SPECULAR);

    gl_FragColor = vec4( (ambient + diffuse) * tex_color.xyz, 1.0);
}