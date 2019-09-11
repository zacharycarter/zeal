// shaderc command line:
// shadercRelease.exe -f .\src\terrain\terrain_init_cs.sc -o .\dx11\compute\terrain_init_cs.bin --varyingdef .\src\terrain\varying.def.sc -i ..\..\bgfx\src\ -i .\src --type compute --platform windows -p cs_5_0 --debug --disasm -O 0

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
static float4x4 u_modelViewProj;
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
uniform float4 u_params[2];
RWBuffer<uint> u_SubdBufferOut : register(u[1]);
RWBuffer<uint> u_CulledSubdBuffer : register(u[2]);
RWBuffer<uint4> indirectBuffer : register(u[3]);
RWBuffer<uint> atomicCounterBuffer : register(u[4]);
RWBuffer<uint> u_SubdBufferIn : register(u[8]);
[numthreads(1u, 1u, 1u)]
void main( )
{
uint subd = 6 << (2 * int(u_params[1].x) - 1);
if((2 * int(u_params[1].x) - 1) <= 0) {
subd = 3u;
}
indirectBuffer[0u*2+0] = uint4(subd, 0u, 0u, 0u); indirectBuffer[0u*2+1] = uint4(0u, 0u, 0u, 0u);
indirectBuffer[1u*2+0] = uint4(2u / 32u + 1u, 1u, 1u, 0u);
u_SubdBufferOut[0] = 0;
u_SubdBufferOut[1] = 1;
u_SubdBufferOut[2] = 1;
u_SubdBufferOut[3] = 1;
u_CulledSubdBuffer[0] = 0;
u_CulledSubdBuffer[1] = 1;
u_CulledSubdBuffer[2] = 1;
u_CulledSubdBuffer[3] = 1;
u_SubdBufferIn[0] = 0;
u_SubdBufferIn[1] = 1;
u_SubdBufferIn[2] = 1;
u_SubdBufferIn[3] = 1;
uint tmp;
InterlockedExchange(atomicCounterBuffer[0], 0, tmp);
InterlockedExchange(atomicCounterBuffer[1], 0, tmp);
InterlockedExchange(atomicCounterBuffer[2], 2, tmp);
}
