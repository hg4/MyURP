#ifndef TRUNK_WITH_MOSS_INPUT_INCLUDED
#define TRUNK_WITH_MOSS_INPUT_INCLUDED
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_MossMap);
SAMPLER(sampler_MossMap);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
//if use batcher, geometry shader will cause problem.
//CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _MossMap_ST;
half4 _BaseColor;
//float4 _SpecColor;
half _Shininess;
int _ShellAmount;
half _ShellStep;
half _AlphaCutout;
half _MossRoughness;
half4 _MossBaseColor;
half4 _MossHighColor;
half _Occlusion;
//float4 _MossShadowColor;
half4 _SSSColor;
half _BackSSDistortion;
half _SSSIntensity;
half _RimLightPower;
half _Cutoff;
half _IntensityGI;
half _NormalScale;
//CBUFFER_END

half4 GetBaseColor()
{
    return _BaseColor;
}

half4 GetBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
}
float3 GetNormalMap(float2 uv)
{
    float4 sample = SAMPLE_TEXTURE2D(_NormalMap, sampler_MossMap, uv);
    return UnpackNormalScale(sample, _NormalScale);
}
float3 GetNormalMapLOD(float2 uv,float lod)
{
    float4 sample = SAMPLE_TEXTURE2D_LOD(_NormalMap, sampler_NormalMap, uv,lod);
    return UnpackNormalScale(sample, _NormalScale);
}
half4 GetMossMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_MossMap, sampler_MossMap, uv);
}
half4 GetMossBaseColor()
{
    return _MossBaseColor;
}
half4 GetMossHighColor()
{
    return _MossHighColor;
}
//float4 GetMossShadowColor()
//{
//    return _MossShadowColor;
//}
half GetShellStep()
{
    return _ShellStep;
}
half3 GetSSSColor()
{
    return _SSSColor.rgb;
}
half GetSSSIntensity()
{
    return _SSSIntensity;
}
half GetBackSSDistortion()
{
    return _BackSSDistortion;
}
half GetRimLightPower()
{
    return _RimLightPower;
}
half GetSmoothness()
{
    return (1 - _Shininess)*32;
}
half GetAlphaCutout()
{
    return 1-_AlphaCutout;
}
half GetIntensityGI()
{
    return _IntensityGI;
}
half GetCutoff()
{
    return _Cutoff;
}
half GetOcclusion()
{
    return _Occlusion;
}
int GetShellAmount()
{
    return _ShellAmount;
}
half GetMossRoughness()
{
    return 1 - _MossRoughness;
}

#endif