// shaderc command line:
// shadercRelease.exe -f .\src\terrain\terrain_render_vs.sc -o .\dx11\vertex\terrain_render_vs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type vertex --platform windows -p vs_5_0 --debug -O 0

struct Output
{
float4 gl_Position : SV_POSITION;
float2 v_texcoord0 : TEXCOORD0;
};
float intBitsToFloat(int _x) { return asfloat(_x); }
float2 intBitsToFloat(uint2 _x) { return asfloat(_x); }
float3 intBitsToFloat(uint3 _x) { return asfloat(_x); }
float4 intBitsToFloat(uint4 _x) { return asfloat(_x); }
float uintBitsToFloat(uint _x) { return asfloat(_x); }
float2 uintBitsToFloat(uint2 _x) { return asfloat(_x); }
float3 uintBitsToFloat(uint3 _x) { return asfloat(_x); }
float4 uintBitsToFloat(uint4 _x) { return asfloat(_x); }
uint floatBitsToUint(float _x) { return asuint(_x); }
uint2 floatBitsToUint(float2 _x) { return asuint(_x); }
uint3 floatBitsToUint(float3 _x) { return asuint(_x); }
uint4 floatBitsToUint(float4 _x) { return asuint(_x); }
int floatBitsToInt(float _x) { return asint(_x); }
int2 floatBitsToInt(float2 _x) { return asint(_x); }
int3 floatBitsToInt(float3 _x) { return asint(_x); }
int4 floatBitsToInt(float4 _x) { return asint(_x); }
uint bitfieldReverse(uint _x) { return reversebits(_x); }
uint2 bitfieldReverse(uint2 _x) { return reversebits(_x); }
uint3 bitfieldReverse(uint3 _x) { return reversebits(_x); }
uint4 bitfieldReverse(uint4 _x) { return reversebits(_x); }
uint packHalf2x16(float2 _x)
{
return (f32tof16(_x.y)<<16) | f32tof16(_x.x);
}
float2 unpackHalf2x16(uint _x)
{
return float2(f16tof32(_x & 0xffff), f16tof32(_x >> 16) );
}
struct BgfxSampler2D
{
SamplerState m_sampler;
Texture2D m_texture;
};
struct BgfxISampler2D
{
Texture2D<int4> m_texture;
};
struct BgfxUSampler2D
{
Texture2D<uint4> m_texture;
};
struct BgfxSampler2DArray
{
SamplerState m_sampler;
Texture2DArray m_texture;
};
struct BgfxSampler2DShadow
{
SamplerComparisonState m_sampler;
Texture2D m_texture;
};
struct BgfxSampler2DArrayShadow
{
SamplerComparisonState m_sampler;
Texture2DArray m_texture;
};
struct BgfxSampler3D
{
SamplerState m_sampler;
Texture3D m_texture;
};
struct BgfxISampler3D
{
Texture3D<int4> m_texture;
};
struct BgfxUSampler3D
{
Texture3D<uint4> m_texture;
};
struct BgfxSamplerCube
{
SamplerState m_sampler;
TextureCube m_texture;
};
struct BgfxSamplerCubeShadow
{
SamplerComparisonState m_sampler;
TextureCube m_texture;
};
struct BgfxSampler2DMS
{
Texture2DMS<float4> m_texture;
};
float4 bgfxTexture2D(BgfxSampler2D _sampler, float2 _coord)
{
return _sampler.m_texture.Sample(_sampler.m_sampler, _coord);
}
float4 bgfxTexture2DLod(BgfxSampler2D _sampler, float2 _coord, float _level)
{
return _sampler.m_texture.SampleLevel(_sampler.m_sampler, _coord, _level);
}
float4 bgfxTexture2DLodOffset(BgfxSampler2D _sampler, float2 _coord, float _level, int2 _offset)
{
return _sampler.m_texture.SampleLevel(_sampler.m_sampler, _coord, _level, _offset);
}
float4 bgfxTexture2DProj(BgfxSampler2D _sampler, float3 _coord)
{
float2 coord = _coord.xy * rcp(_coord.z);
return _sampler.m_texture.Sample(_sampler.m_sampler, coord);
}
float4 bgfxTexture2DProj(BgfxSampler2D _sampler, float4 _coord)
{
float2 coord = _coord.xy * rcp(_coord.w);
return _sampler.m_texture.Sample(_sampler.m_sampler, coord);
}
float4 bgfxTexture2DGrad(BgfxSampler2D _sampler, float2 _coord, float2 _dPdx, float2 _dPdy)
{
return _sampler.m_texture.SampleGrad(_sampler.m_sampler, _coord, _dPdx, _dPdy);
}
float4 bgfxTexture2DArray(BgfxSampler2DArray _sampler, float3 _coord)
{
return _sampler.m_texture.Sample(_sampler.m_sampler, _coord);
}
float4 bgfxTexture2DArrayLod(BgfxSampler2DArray _sampler, float3 _coord, float _lod)
{
return _sampler.m_texture.SampleLevel(_sampler.m_sampler, _coord, _lod);
}
float4 bgfxTexture2DArrayLodOffset(BgfxSampler2DArray _sampler, float3 _coord, float _level, int2 _offset)
{
return _sampler.m_texture.SampleLevel(_sampler.m_sampler, _coord, _level, _offset);
}
float bgfxShadow2D(BgfxSampler2DShadow _sampler, float3 _coord)
{
return _sampler.m_texture.SampleCmpLevelZero(_sampler.m_sampler, _coord.xy, _coord.z);
}
float bgfxShadow2DProj(BgfxSampler2DShadow _sampler, float4 _coord)
{
float3 coord = _coord.xyz * rcp(_coord.w);
return _sampler.m_texture.SampleCmpLevelZero(_sampler.m_sampler, coord.xy, coord.z);
}
float4 bgfxShadow2DArray(BgfxSampler2DArrayShadow _sampler, float4 _coord)
{
return _sampler.m_texture.SampleCmpLevelZero(_sampler.m_sampler, _coord.xyz, _coord.w);
}
float4 bgfxTexture3D(BgfxSampler3D _sampler, float3 _coord)
{
return _sampler.m_texture.Sample(_sampler.m_sampler, _coord);
}
float4 bgfxTexture3DLod(BgfxSampler3D _sampler, float3 _coord, float _level)
{
return _sampler.m_texture.SampleLevel(_sampler.m_sampler, _coord, _level);
}
int4 bgfxTexture3D(BgfxISampler3D _sampler, float3 _coord)
{
uint3 size;
_sampler.m_texture.GetDimensions(size.x, size.y, size.z);
return _sampler.m_texture.Load(int4(_coord * size, 0) );
}
uint4 bgfxTexture3D(BgfxUSampler3D _sampler, float3 _coord)
{
uint3 size;
_sampler.m_texture.GetDimensions(size.x, size.y, size.z);
return _sampler.m_texture.Load(int4(_coord * size, 0) );
}
float4 bgfxTextureCube(BgfxSamplerCube _sampler, float3 _coord)
{
return _sampler.m_texture.Sample(_sampler.m_sampler, _coord);
}
float4 bgfxTextureCubeLod(BgfxSamplerCube _sampler, float3 _coord, float _level)
{
return _sampler.m_texture.SampleLevel(_sampler.m_sampler, _coord, _level);
}
float bgfxShadowCube(BgfxSamplerCubeShadow _sampler, float4 _coord)
{
return _sampler.m_texture.SampleCmpLevelZero(_sampler.m_sampler, _coord.xyz, _coord.w);
}
float4 bgfxTexelFetch(BgfxSampler2D _sampler, int2 _coord, int _lod)
{
return _sampler.m_texture.Load(int3(_coord, _lod) );
}
float4 bgfxTexelFetchOffset(BgfxSampler2D _sampler, int2 _coord, int _lod, int2 _offset)
{
return _sampler.m_texture.Load(int3(_coord, _lod), _offset );
}
float2 bgfxTextureSize(BgfxSampler2D _sampler, int _lod)
{
float2 result;
_sampler.m_texture.GetDimensions(result.x, result.y);
return result;
}
float4 bgfxTextureGather(BgfxSampler2D _sampler, float2 _coord)
{
return _sampler.m_texture.GatherRed(_sampler.m_sampler, _coord );
}
float4 bgfxTextureGatherOffset(BgfxSampler2D _sampler, float2 _coord, int2 _offset)
{
return _sampler.m_texture.GatherRed(_sampler.m_sampler, _coord, _offset );
}
float4 bgfxTextureGather(BgfxSampler2DArray _sampler, float3 _coord)
{
return _sampler.m_texture.GatherRed(_sampler.m_sampler, _coord );
}
int4 bgfxTexelFetch(BgfxISampler2D _sampler, int2 _coord, int _lod)
{
return _sampler.m_texture.Load(int3(_coord, _lod) );
}
uint4 bgfxTexelFetch(BgfxUSampler2D _sampler, int2 _coord, int _lod)
{
return _sampler.m_texture.Load(int3(_coord, _lod) );
}
float4 bgfxTexelFetch(BgfxSampler2DMS _sampler, int2 _coord, int _sampleIdx)
{
return _sampler.m_texture.Load(_coord, _sampleIdx);
}
float4 bgfxTexelFetch(BgfxSampler2DArray _sampler, int3 _coord, int _lod)
{
return _sampler.m_texture.Load(int4(_coord, _lod) );
}
float4 bgfxTexelFetch(BgfxSampler3D _sampler, int3 _coord, int _lod)
{
return _sampler.m_texture.Load(int4(_coord, _lod) );
}
float3 bgfxTextureSize(BgfxSampler3D _sampler, int _lod)
{
float3 result;
_sampler.m_texture.GetDimensions(result.x, result.y, result.z);
return result;
}
float3 instMul(float3 _vec, float3x3 _mtx) { return mul(_mtx, _vec); }
float3 instMul(float3x3 _mtx, float3 _vec) { return mul(_vec, _mtx); }
float4 instMul(float4 _vec, float4x4 _mtx) { return mul(_mtx, _vec); }
float4 instMul(float4x4 _mtx, float4 _vec) { return mul(_vec, _mtx); }
bool2 lessThan(float2 _a, float2 _b) { return _a < _b; }
bool3 lessThan(float3 _a, float3 _b) { return _a < _b; }
bool4 lessThan(float4 _a, float4 _b) { return _a < _b; }
bool2 lessThanEqual(float2 _a, float2 _b) { return _a <= _b; }
bool3 lessThanEqual(float3 _a, float3 _b) { return _a <= _b; }
bool4 lessThanEqual(float4 _a, float4 _b) { return _a <= _b; }
bool2 greaterThan(float2 _a, float2 _b) { return _a > _b; }
bool3 greaterThan(float3 _a, float3 _b) { return _a > _b; }
bool4 greaterThan(float4 _a, float4 _b) { return _a > _b; }
bool2 greaterThanEqual(float2 _a, float2 _b) { return _a >= _b; }
bool3 greaterThanEqual(float3 _a, float3 _b) { return _a >= _b; }
bool4 greaterThanEqual(float4 _a, float4 _b) { return _a >= _b; }
bool2 notEqual(float2 _a, float2 _b) { return _a != _b; }
bool3 notEqual(float3 _a, float3 _b) { return _a != _b; }
bool4 notEqual(float4 _a, float4 _b) { return _a != _b; }
bool2 equal(float2 _a, float2 _b) { return _a == _b; }
bool3 equal(float3 _a, float3 _b) { return _a == _b; }
bool4 equal(float4 _a, float4 _b) { return _a == _b; }
float mix(float _a, float _b, float _t) { return lerp(_a, _b, _t); }
float2 mix(float2 _a, float2 _b, float2 _t) { return lerp(_a, _b, _t); }
float3 mix(float3 _a, float3 _b, float3 _t) { return lerp(_a, _b, _t); }
float4 mix(float4 _a, float4 _b, float4 _t) { return lerp(_a, _b, _t); }
float mod(float _a, float _b) { return _a - _b * floor(_a / _b); }
float2 mod(float2 _a, float2 _b) { return _a - _b * floor(_a / _b); }
float3 mod(float3 _a, float3 _b) { return _a - _b * floor(_a / _b); }
float4 mod(float4 _a, float4 _b) { return _a - _b * floor(_a / _b); }
float2 vec2_splat(float _x) { return float2(_x, _x); }
float3 vec3_splat(float _x) { return float3(_x, _x, _x); }
float4 vec4_splat(float _x) { return float4(_x, _x, _x, _x); }
uint2 uvec2_splat(uint _x) { return uint2(_x, _x); }
uint3 uvec3_splat(uint _x) { return uint3(_x, _x, _x); }
uint4 uvec4_splat(uint _x) { return uint4(_x, _x, _x, _x); }
float4x4 mtxFromRows(float4 _0, float4 _1, float4 _2, float4 _3)
{
return float4x4(_0, _1, _2, _3);
}
float4x4 mtxFromCols(float4 _0, float4 _1, float4 _2, float4 _3)
{
return transpose(float4x4(_0, _1, _2, _3) );
}
float3x3 mtxFromCols(float3 _0, float3 _1, float3 _2)
{
return transpose(float3x3(_0, _1, _2) );
}
static float4 u_viewRect;
static float4 u_viewTexel;
static float4x4 u_view;
static float4x4 u_invView;
static float4x4 u_proj;
static float4x4 u_invProj;
static float4x4 u_viewProj;
static float4x4 u_invViewProj;
static float4x4 u_model[32];
static float4x4 u_modelView;
uniform float4x4 u_modelViewProj;
static float4 u_alphaRef4;
struct BgfxROImage2D_rgba8 { Texture2D<unorm float4> m_texture; }; struct BgfxRWImage2D_rgba8 { RWTexture2D<unorm float4> m_texture; }; struct BgfxROImage2DArray_rgba8 { Texture2DArray<unorm float4> m_texture; }; struct BgfxRWImage2DArray_rgba8 { RWTexture2DArray<unorm float4> m_texture; }; struct BgfxROImage3D_rgba8 { Texture3D<unorm float4> m_texture; }; struct BgfxRWImage3D_rgba8 { RWTexture3D<unorm float4> m_texture; }; float4 imageLoad(BgfxROImage2D_rgba8 _image, int2 _uv) { return _image.m_texture[_uv].xyzw; } int2 imageSize(BgfxROImage2D_rgba8 _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } float4 imageLoad(BgfxRWImage2D_rgba8 _image, int2 _uv) { return _image.m_texture[_uv].xyzw; } int2 imageSize(BgfxRWImage2D_rgba8 _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_rgba8 _image, int2 _uv, float4 _value) { _image.m_texture[_uv] = _value.xyzw; } float4 imageLoad(BgfxROImage2DArray_rgba8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxROImage2DArray_rgba8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage2DArray_rgba8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } void imageStore(BgfxRWImage2DArray_rgba8 _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xyzw; } int3 imageSize(BgfxRWImage2DArray_rgba8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxROImage3D_rgba8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxROImage3D_rgba8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage3D_rgba8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxRWImage3D_rgba8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_rgba8 _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xyzw; }
struct BgfxROImage2D_rg8 { Texture2D<unorm float2> m_texture; }; struct BgfxRWImage2D_rg8 { RWTexture2D<unorm float2> m_texture; }; struct BgfxROImage2DArray_rg8 { Texture2DArray<unorm float2> m_texture; }; struct BgfxRWImage2DArray_rg8 { RWTexture2DArray<unorm float2> m_texture; }; struct BgfxROImage3D_rg8 { Texture3D<unorm float2> m_texture; }; struct BgfxRWImage3D_rg8 { RWTexture3D<unorm float2> m_texture; }; float4 imageLoad(BgfxROImage2D_rg8 _image, int2 _uv) { return _image.m_texture[_uv].xyyy; } int2 imageSize(BgfxROImage2D_rg8 _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } float4 imageLoad(BgfxRWImage2D_rg8 _image, int2 _uv) { return _image.m_texture[_uv].xyyy; } int2 imageSize(BgfxRWImage2D_rg8 _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_rg8 _image, int2 _uv, float4 _value) { _image.m_texture[_uv] = _value.xy; } float4 imageLoad(BgfxROImage2DArray_rg8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxROImage2DArray_rg8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage2DArray_rg8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } void imageStore(BgfxRWImage2DArray_rg8 _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xy; } int3 imageSize(BgfxRWImage2DArray_rg8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxROImage3D_rg8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxROImage3D_rg8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage3D_rg8 _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxRWImage3D_rg8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_rg8 _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xy; }
struct BgfxROImage2D_r8 { Texture2D<unorm float> m_texture; }; struct BgfxRWImage2D_r8 { RWTexture2D<unorm float> m_texture; }; struct BgfxROImage2DArray_r8 { Texture2DArray<unorm float> m_texture; }; struct BgfxRWImage2DArray_r8 { RWTexture2DArray<unorm float> m_texture; }; struct BgfxROImage3D_r8 { Texture3D<unorm float> m_texture; }; struct BgfxRWImage3D_r8 { RWTexture3D<unorm float> m_texture; }; float4 imageLoad(BgfxROImage2D_r8 _image, int2 _uv) { return _image.m_texture[_uv].xxxx; } int2 imageSize(BgfxROImage2D_r8 _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } float4 imageLoad(BgfxRWImage2D_r8 _image, int2 _uv) { return _image.m_texture[_uv].xxxx; } int2 imageSize(BgfxRWImage2D_r8 _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_r8 _image, int2 _uv, float4 _value) { _image.m_texture[_uv] = _value.x; } float4 imageLoad(BgfxROImage2DArray_r8 _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxROImage2DArray_r8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage2DArray_r8 _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } void imageStore(BgfxRWImage2DArray_r8 _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.x; } int3 imageSize(BgfxRWImage2DArray_r8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxROImage3D_r8 _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxROImage3D_r8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage3D_r8 _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxRWImage3D_r8 _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_r8 _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.x; }
struct BgfxROImage2D_rg16f { Texture2D<float2> m_texture; }; struct BgfxRWImage2D_rg16f { RWTexture2D<float2> m_texture; }; struct BgfxROImage2DArray_rg16f { Texture2DArray<float2> m_texture; }; struct BgfxRWImage2DArray_rg16f { RWTexture2DArray<float2> m_texture; }; struct BgfxROImage3D_rg16f { Texture3D<float2> m_texture; }; struct BgfxRWImage3D_rg16f { RWTexture3D<float2> m_texture; }; float4 imageLoad(BgfxROImage2D_rg16f _image, int2 _uv) { return _image.m_texture[_uv].xyyy; } int2 imageSize(BgfxROImage2D_rg16f _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } float4 imageLoad(BgfxRWImage2D_rg16f _image, int2 _uv) { return _image.m_texture[_uv].xyyy; } int2 imageSize(BgfxRWImage2D_rg16f _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_rg16f _image, int2 _uv, float4 _value) { _image.m_texture[_uv] = _value.xy; } float4 imageLoad(BgfxROImage2DArray_rg16f _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxROImage2DArray_rg16f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage2DArray_rg16f _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } void imageStore(BgfxRWImage2DArray_rg16f _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xy; } int3 imageSize(BgfxRWImage2DArray_rg16f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxROImage3D_rg16f _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxROImage3D_rg16f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage3D_rg16f _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxRWImage3D_rg16f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_rg16f _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xy; }
struct BgfxROImage2D_rgba16f { Texture2D<float4> m_texture; }; struct BgfxRWImage2D_rgba16f { RWTexture2D<float4> m_texture; }; struct BgfxROImage2DArray_rgba16f { Texture2DArray<float4> m_texture; }; struct BgfxRWImage2DArray_rgba16f { RWTexture2DArray<float4> m_texture; }; struct BgfxROImage3D_rgba16f { Texture3D<float4> m_texture; }; struct BgfxRWImage3D_rgba16f { RWTexture3D<float4> m_texture; };
struct BgfxROImage2D_r16f { Texture2D<float> m_texture; }; struct BgfxRWImage2D_r16f { RWTexture2D<float> m_texture; }; struct BgfxROImage2DArray_r16f { Texture2DArray<float> m_texture; }; struct BgfxRWImage2DArray_r16f { RWTexture2DArray<float> m_texture; }; struct BgfxROImage3D_r16f { Texture3D<float> m_texture; }; struct BgfxRWImage3D_r16f { RWTexture3D<float> m_texture; };
struct BgfxROImage2D_r32f { Texture2D<float> m_texture; }; struct BgfxRWImage2D_r32f { RWTexture2D<float> m_texture; }; struct BgfxROImage2DArray_r32f { Texture2DArray<float> m_texture; }; struct BgfxRWImage2DArray_r32f { RWTexture2DArray<float> m_texture; }; struct BgfxROImage3D_r32f { Texture3D<float> m_texture; }; struct BgfxRWImage3D_r32f { RWTexture3D<float> m_texture; }; float4 imageLoad(BgfxROImage2D_r32f _image, int2 _uv) { return _image.m_texture[_uv].xxxx; } int2 imageSize(BgfxROImage2D_r32f _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } float4 imageLoad(BgfxRWImage2D_r32f _image, int2 _uv) { return _image.m_texture[_uv].xxxx; } int2 imageSize(BgfxRWImage2D_r32f _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_r32f _image, int2 _uv, float4 _value) { _image.m_texture[_uv] = _value.x; } float4 imageLoad(BgfxROImage2DArray_r32f _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxROImage2DArray_r32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage2DArray_r32f _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } void imageStore(BgfxRWImage2DArray_r32f _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.x; } int3 imageSize(BgfxRWImage2DArray_r32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxROImage3D_r32f _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxROImage3D_r32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage3D_r32f _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxRWImage3D_r32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_r32f _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.x; }
struct BgfxROImage2D_rgba32f { Texture2D<float4> m_texture; }; struct BgfxRWImage2D_rgba32f { RWTexture2D<float4> m_texture; }; struct BgfxROImage2DArray_rgba32f { Texture2DArray<float4> m_texture; }; struct BgfxRWImage2DArray_rgba32f { RWTexture2DArray<float4> m_texture; }; struct BgfxROImage3D_rgba32f { Texture3D<float4> m_texture; }; struct BgfxRWImage3D_rgba32f { RWTexture3D<float4> m_texture; }; float4 imageLoad(BgfxROImage2D_rgba32f _image, int2 _uv) { return _image.m_texture[_uv].xyzw; } int2 imageSize(BgfxROImage2D_rgba32f _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } float4 imageLoad(BgfxRWImage2D_rgba32f _image, int2 _uv) { return _image.m_texture[_uv].xyzw; } int2 imageSize(BgfxRWImage2D_rgba32f _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_rgba32f _image, int2 _uv, float4 _value) { _image.m_texture[_uv] = _value.xyzw; } float4 imageLoad(BgfxROImage2DArray_rgba32f _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxROImage2DArray_rgba32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage2DArray_rgba32f _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } void imageStore(BgfxRWImage2DArray_rgba32f _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xyzw; } int3 imageSize(BgfxRWImage2DArray_rgba32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxROImage3D_rgba32f _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxROImage3D_rgba32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } float4 imageLoad(BgfxRWImage3D_rgba32f _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxRWImage3D_rgba32f _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_rgba32f _image, int3 _uvw, float4 _value) { _image.m_texture[_uvw] = _value.xyzw; }
struct BgfxROImage2D_r32ui { Texture2D<uint> m_texture; }; struct BgfxRWImage2D_r32ui { RWTexture2D<uint> m_texture; }; struct BgfxROImage2DArray_r32ui { Texture2DArray<uint> m_texture; }; struct BgfxRWImage2DArray_r32ui { RWTexture2DArray<uint> m_texture; }; struct BgfxROImage3D_r32ui { Texture3D<uint> m_texture; }; struct BgfxRWImage3D_r32ui { RWTexture3D<uint> m_texture; }; uint4 imageLoad(BgfxROImage2D_r32ui _image, int2 _uv) { return _image.m_texture[_uv].xxxx; } int2 imageSize(BgfxROImage2D_r32ui _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } uint4 imageLoad(BgfxRWImage2D_r32ui _image, int2 _uv) { return _image.m_texture[_uv].xxxx; } int2 imageSize(BgfxRWImage2D_r32ui _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_r32ui _image, int2 _uv, uint4 _value) { _image.m_texture[_uv] = _value.x; } uint4 imageLoad(BgfxROImage2DArray_r32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxROImage2DArray_r32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxRWImage2DArray_r32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } void imageStore(BgfxRWImage2DArray_r32ui _image, int3 _uvw, uint4 _value) { _image.m_texture[_uvw] = _value.x; } int3 imageSize(BgfxRWImage2DArray_r32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxROImage3D_r32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxROImage3D_r32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxRWImage3D_r32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xxxx; } int3 imageSize(BgfxRWImage3D_r32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_r32ui _image, int3 _uvw, uint4 _value) { _image.m_texture[_uvw] = _value.x; }
struct BgfxROImage2D_rg32ui { Texture2D<uint2> m_texture; }; struct BgfxRWImage2D_rg32ui { RWTexture2D<uint2> m_texture; }; struct BgfxROImage2DArray_rg32ui { Texture2DArray<uint2> m_texture; }; struct BgfxRWImage2DArray_rg32ui { RWTexture2DArray<uint2> m_texture; }; struct BgfxROImage3D_rg32ui { Texture3D<uint2> m_texture; }; struct BgfxRWImage3D_rg32ui { RWTexture3D<uint2> m_texture; }; uint4 imageLoad(BgfxROImage2D_rg32ui _image, int2 _uv) { return _image.m_texture[_uv].xyyy; } int2 imageSize(BgfxROImage2D_rg32ui _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } uint4 imageLoad(BgfxRWImage2D_rg32ui _image, int2 _uv) { return _image.m_texture[_uv].xyyy; } int2 imageSize(BgfxRWImage2D_rg32ui _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_rg32ui _image, int2 _uv, uint4 _value) { _image.m_texture[_uv] = _value.xy; } uint4 imageLoad(BgfxROImage2DArray_rg32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxROImage2DArray_rg32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxRWImage2DArray_rg32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } void imageStore(BgfxRWImage2DArray_rg32ui _image, int3 _uvw, uint4 _value) { _image.m_texture[_uvw] = _value.xy; } int3 imageSize(BgfxRWImage2DArray_rg32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxROImage3D_rg32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxROImage3D_rg32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxRWImage3D_rg32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyyy; } int3 imageSize(BgfxRWImage3D_rg32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_rg32ui _image, int3 _uvw, uint4 _value) { _image.m_texture[_uvw] = _value.xy; }
struct BgfxROImage2D_rgba32ui { Texture2D<uint4> m_texture; }; struct BgfxRWImage2D_rgba32ui { RWTexture2D<uint4> m_texture; }; struct BgfxROImage2DArray_rgba32ui { Texture2DArray<uint4> m_texture; }; struct BgfxRWImage2DArray_rgba32ui { RWTexture2DArray<uint4> m_texture; }; struct BgfxROImage3D_rgba32ui { Texture3D<uint4> m_texture; }; struct BgfxRWImage3D_rgba32ui { RWTexture3D<uint4> m_texture; }; uint4 imageLoad(BgfxROImage2D_rgba32ui _image, int2 _uv) { return _image.m_texture[_uv].xyzw; } int2 imageSize(BgfxROImage2D_rgba32ui _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } uint4 imageLoad(BgfxRWImage2D_rgba32ui _image, int2 _uv) { return _image.m_texture[_uv].xyzw; } int2 imageSize(BgfxRWImage2D_rgba32ui _image) { uint2 result; _image.m_texture.GetDimensions(result.x, result.y); return int2(result); } void imageStore(BgfxRWImage2D_rgba32ui _image, int2 _uv, uint4 _value) { _image.m_texture[_uv] = _value.xyzw; } uint4 imageLoad(BgfxROImage2DArray_rgba32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxROImage2DArray_rgba32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxRWImage2DArray_rgba32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } void imageStore(BgfxRWImage2DArray_rgba32ui _image, int3 _uvw, uint4 _value) { _image.m_texture[_uvw] = _value.xyzw; } int3 imageSize(BgfxRWImage2DArray_rgba32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxROImage3D_rgba32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxROImage3D_rgba32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } uint4 imageLoad(BgfxRWImage3D_rgba32ui _image, int3 _uvw) { return _image.m_texture[_uvw].xyzw; } int3 imageSize(BgfxRWImage3D_rgba32ui _image) { uint3 result; _image.m_texture.GetDimensions(result.x, result.y, result.z); return int3(result); } void imageStore(BgfxRWImage3D_rgba32ui _image, int3 _uvw, uint4 _value) { _image.m_texture[_uvw] = _value.xyzw; }
void imageAtomicAdd(BgfxRWImage2D_r32ui _image, int2 _uv, uint4 _value) { InterlockedAdd(_image.m_texture[_uv], _value.x); }
float3x4 mtxFromRows(float4 _0, float4 _1, float4 _2)
{
return float3x4(_0, _1, _2);
}
float4 mtxGetRow(float3x4 _0, uint row)
{
return float4(_0[row]);
}
float4 mtxGetRow(float4x4 _0, uint row)
{
return float4(_0[row]);
}
float4 mtxGetColumn(float4x4 _0, uint column)
{
return float4(_0[0][column], _0[1][column], _0[2][column], _0[3][column]);
}
float mtxGetElement(float4x4 _0, uint column, uint row)
{
return _0[row][column];
}
uint findMSB(uint x)
{
uint i;
uint mask;
uint res = -1;
for (i = 0; i < 32; i++)
{
mask = 0x80000000 >> i;
if ((x & mask) != 0)
{
res = 31 - i;
break;
}
}
return res;
}
uint parentKey(in uint key)
{
return (key >> 1u);
}
void childrenKeys(in uint key, out uint children[2])
{
children[0] = (key << 1u) | 0u;
children[1] = (key << 1u) | 1u;
}
bool isRootKey(in uint key)
{
return (key == 1u);
}
bool isLeafKey(in uint key)
{
return findMSB(key) == 31;
}
bool isChildZeroKey(in uint key)
{
return ((key & 1u) == 0u);
}
float3 berp(in float3 v[3], in float2 u)
{
return v[0] + u.x * (v[1] - v[0]) + u.y * (v[2] - v[0]);
}
float4 berp(in float4 v[3], in float2 u)
{
return v[0] + u.x * (v[1] - v[0]) + u.y * (v[2] - v[0]);
}
float3x3 bitToXform(in uint bit)
{
float b = float(bit);
float c = 1.0f - b;
float3 c1 = float3(0.0f, c , b );
float3 c2 = float3(0.5f, b , 0.0f);
float3 c3 = float3(0.5f, 0.0f, c );
return mtxFromCols(c1, c2, c3);
}
float3x3 keyToXform(in uint key)
{
float3 c1 = float3(1.0f, 0.0f, 0.0f);
float3 c2 = float3(0.0f, 1.0f, 0.0f);
float3 c3 = float3(0.0f, 0.0f, 1.0f);
float3x3 xf = mtxFromCols(c1, c2, c3);
while (key > 1u) {
xf = mul(xf, bitToXform(key & 1u));
key = key >> 1u;
}
return xf;
}
float3x3 keyToXform(in uint key, out float3x3 xfp)
{
xfp = keyToXform(parentKey(key));
return keyToXform(key);
}
void subd(in uint key, in float4 v_in[3], out float4 v_out[3])
{
float3x3 xf = keyToXform(key);
float3x4 m = mtxFromRows(v_in[0], v_in[1], v_in[2]);
float3x4 v = mul(xf, m);
v_out[0] = mtxGetRow(v, 0);
v_out[1] = mtxGetRow(v, 1);
v_out[2] = mtxGetRow(v, 2);
}
void subd(in uint key, in float4 v_in[3], out float4 v_out[3], out float4 v_out_p[3])
{
float3x3 xfp; float3x3 xf = keyToXform(key, xfp);
float3x4 m = mtxFromRows(v_in[0], v_in[1], v_in[2]);
float3x4 v = mul(xf, m);
float3x4 vp = mul(xfp, m);
v_out[0] = mtxGetRow(v, 0);
v_out[1] = mtxGetRow(v, 1);
v_out[2] = mtxGetRow(v, 2);
v_out_p[0] = mtxGetRow(vp, 0);
v_out_p[1] = mtxGetRow(vp, 1);
v_out_p[2] = mtxGetRow(vp, 2);
}
uniform float4 u_params[2];
RWBuffer<uint> u_AtomicCounterBuffer : register(u[4]);
RWBuffer<uint> u_SubdBufferOut : register(u[1]);
uniform SamplerState u_DmapSamplerSampler : register(s[0]); uniform Texture2D u_DmapSamplerTexture : register(t[0]); static BgfxSampler2D u_DmapSampler = { u_DmapSamplerSampler, u_DmapSamplerTexture };
uniform SamplerState u_SmapSamplerSampler : register(s[1]); uniform Texture2D u_SmapSamplerTexture : register(t[1]); static BgfxSampler2D u_SmapSampler = { u_SmapSamplerSampler, u_SmapSamplerTexture };
float dmap(float2 pos)
{
return (bgfxTexture2DLod(u_DmapSampler, pos * 0.5 + 0.5, 0).x) * u_params[0].x;
}
float distanceToLod(float z, float lodFactor)
{
return -2.0 * log2(clamp(z * lodFactor, 0.0f, 1.0f));
}
float computeLod(float3 c)
{
c.z += dmap(mtxGetColumn(u_invView, 3).xy);
float3 cxf = mul(u_modelView, float4(c.x, c.y, c.z, 1)).xyz;
float z = length(cxf);
return distanceToLod(z, u_params[0].y);
}
float computeLod(in float4 v[3])
{
float3 c = (v[1].xyz + v[2].xyz) / 2.0;
return computeLod(c);
}
float computeLod(in float3 v[3])
{
float3 c = (v[1].xyz + v[2].xyz) / 2.0;
return computeLod(c);
}
void writeKey(uint primID, uint key)
{
uint idx = 0;
InterlockedAdd(u_AtomicCounterBuffer[0], 2, idx);
u_SubdBufferOut[idx] = primID;
u_SubdBufferOut[idx+1] = key;
}
void updateSubdBuffer(
uint primID
, uint key
, uint targetLod
, uint parentLod
, bool isVisible
)
{
uint keyLod = findMSB(key);
if ( keyLod < targetLod && !isLeafKey(key) && isVisible)
{
uint children[2]; childrenKeys(key, children);
writeKey(primID, children[0]);
writeKey(primID, children[1]);
}
else if ( keyLod < (parentLod + 1) && isVisible)
{
writeKey(primID, key);
}
else
{
if ( isRootKey(key))
{
writeKey(primID, key);
}
else if ( isChildZeroKey(key)) {
writeKey(primID, parentKey(key));
}
}
}
void updateSubdBuffer(uint primID, uint key, uint targetLod, uint parentLod)
{
updateSubdBuffer(primID, key, targetLod, parentLod, true);
}
Buffer<uint> u_CulledSubdBuffer : register(t[2]);
Buffer<float4> u_VertexBuffer : register(t[3]);
Buffer<uint> u_IndexBuffer : register(t[4]);
Output main( float2 a_texcoord0 : TEXCOORD0 , uint gl_InstanceID : SV_InstanceID) { Output _varying_; _varying_.v_texcoord0 = float2(0.0, 0.0);;
{
int threadID = gl_InstanceID;
uint primID = u_CulledSubdBuffer[threadID*2];
float4 v_in[3];
v_in[0] = u_VertexBuffer[u_IndexBuffer[primID * 3 ]];
v_in[1] = u_VertexBuffer[u_IndexBuffer[primID * 3 + 1]];
v_in[2] = u_VertexBuffer[u_IndexBuffer[primID * 3 + 2]];
uint key = u_CulledSubdBuffer[threadID*2+1];
float4 v[3];
subd(key, v_in, v);
float4 finalVertex = berp(v, a_texcoord0);
finalVertex.z+= dmap(finalVertex.xy);
_varying_.v_texcoord0 = finalVertex.xy * 0.5 + 0.5;
_varying_.gl_Position = mul(u_modelViewProj, finalVertex);
} return _varying_;
}
