#ifndef TOON_LIT_INPUT_INCLUDED
#define TOON_LIT_INPUT_INCLUDED

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
float4 _BaseColor;
float4 _MidColor;
float4 _ShadowColor;
float4 _OutlineColor;
float _OutlineWidth;
float _Cutoff;
float _OcclusionIndirectStrength;
float4 _IndirectLightMinColor;
float _IndirectLightFactor;
float _ReceiveShadowPosOffset;

float _ShadowSmooth;
float _ShadowThreshold;
CBUFFER_END

float GetOutlineWidth()
{
    return _OutlineWidth;
}

float4 GetOutlineColor()
{
    return _OutlineColor;

}

float4 GetBaseColor()
{
    return _BaseColor;
}
float4 GetShadowColor()
{
    return _ShadowColor;
}
float4 GetMidColor()
{
    return _MidColor;
}
float GetShadowSmooth()
{
    return _ShadowSmooth;
}
float GetShadowThreshold()
{
    return _ShadowThreshold;
}

float4 GetBaseMap(float2 uv)
{
    return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
}
#endif