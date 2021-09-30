#ifndef LIT_PHONG_INPUT_INCLUDED
#define LIT_PHONG_INPUT_INCLUDED
TEXTURE2D(_BaseMap);
TEXTURE2D(_SpecularMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_BaseMap);

#ifdef _OUTLINE_ZOFFSET
TEXTURE2D(_OutlineZOffsetMask);
SAMPLER(sampler_OutlineZOffsetMask);
#endif

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _BaseColor;
float4 _SpecColor;
float _Shininess;
float _NormalScale;
float4 _OutlineColor;
float _OutlineWidth;
float _Cutoff;
#ifdef _OUTLINE_ZOFFSET
float _OutlineZOffsetStrength;
float _OutlineZOffsetMaskRemapStart;
float _OutlineZOffsetMaskRemapEnd;
#endif
CBUFFER_END

float4 GetBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
}
float4 GetSpecularMap(float2 uv)
{

    return SAMPLE_TEXTURE2D(_SpecularMap, sampler_BaseMap, uv);
}
float3 GetNormalMap(float2 uv)
{
    float4 sample = SAMPLE_TEXTURE2D(_NormalMap, sampler_BaseMap, uv);
    return UnpackNormalScale(sample, _NormalScale);
}

float GetOutlineWidth()
{
    return _OutlineWidth;
}


float4 GetOutlineColor()
{
    return _OutlineColor;

}

#ifdef _OUTLINE_ZOFFSET
float GetOutlineZOffsetStrength()
{
    return _OutlineZOffsetStrength * 10;
}
float GetOutlineZOffsetMaskRemapStart()
{
    return _OutlineZOffsetMaskRemapStart;
}
float GetOutlineZOffsetMaskRemapEnd()
{
    return _OutlineZOffsetMaskRemapEnd;
}
float GetOutlineZOffsetMask(float2 uv)
{
    return SAMPLE_TEXTURE2D_LOD(_OutlineZOffsetMask, sampler_OutlineZOffsetMask, uv, 0.0).r;
}
#endif

#endif