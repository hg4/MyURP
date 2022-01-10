#ifndef TOON_LIGHTING_INCLUDED
#define TOON_LIGHTING_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

struct ToonSurfaceData
{
    float3 positionWS;
    float3 positionVS;
    float3 positionCS;
    float2 positionSS;
    float2 screenUV;
    float3 normalWS;
    //float3 computeNormalWS;
    float3 baseColor;
    float4 vertexColor;
    float3 viewDirectionWS;
    float alpha;
    float occlusion;
    float4 shadowCoord;
    float3 bakedGI;
#ifdef _FACE_LIGHT_MAP
    float lightmapMask;
#endif
#ifdef _AO_LIGHT_MAP
    float aoMask;
#endif 
#ifdef _HIGHLIGHT_MASK
    float highlightMask;
#endif
};

float3 ShadeGI(ToonSurfaceData surface)
{
    // hide 3D feeling by ignoring all detail SH
    // SH 1 (only use this)
    // SH 234 (ignored)
    // SH 56789 (ignored)
    // we just want to tint some average envi color only
    float3 averageSH = SampleSH(0);

    // occlusion
    // separated control for indirect occlusion
    float indirectOcclusion = lerp(1, surface.occlusion, _OcclusionIndirectStrength);
    float3 indirectLight = averageSH * (_IndirectLightFactor * indirectOcclusion);
    return max(indirectLight, _IndirectLightMinColor.rgb); // can prevent completely black if lightprobe was not baked
}


float2 GetRampFactor(ToonSurfaceData surface,Light light)
{
    float2 factor = float2(0, 0);
    float halfLambert = (0.5 * dot(surface.normalWS, light.direction) + 0.5);
    float NdotL = dot(surface.normalWS, light.direction);
    float NdotV = dot(surface.normalWS, surface.viewDirectionWS);
    float ramp = 0;
    #if defined(_THREE_STEP) && !defined(_RAMP_MAP)
    float smooth = GetShadowSmooth();
    float v = halfLambert - GetShadowThreshold();
    ramp = smoothstep(0, smooth, v);
    factor.x = ramp;
    //factor.y = 1;
    //float rampA = smoothstep(0, smooth / 2, v);
    //float rampB = smoothstep(smooth / 2, smooth, v);
    //ramp = rampA - rampB;
    //factor.x = ramp;
    //factor.y = 1 - step(smooth / 2, v);
    #else
    ramp = smoothstep(0, GetShadowSmooth(), halfLambert - GetShadowThreshold());
    factor.x = ramp;

    #endif
    float atten = (light.distanceAttenuation * light.shadowAttenuation);

    factor.x *= atten;
    float fac = 1 - step(0.5f,atten);
    factor.y = max(factor.y, fac);
    return factor;
    
}
float3 GetRampColor(float2 factor, Light light)
{
    float3 color = float3(0, 0, 0);
#ifndef _RAMP_MAP
    float3 baseColor = GetBaseColor();
    float3 shadowColor = GetShadowColor();
    #ifndef _THREE_STEP
    color = lerp(shadowColor, baseColor, factor.x);
    #else
    float3 midColor = GetMidColor();
    color = factor.x < 0.001 ? shadowColor : factor.x > 0.999 ? baseColor : lerp(midColor,baseColor,factor.x);
    //color = factor.y == 1 ? lerp(midColor, shadowColor, factor.x) :
    //    lerp(baseColor,midColor,factor.x);
    //color = atten == 0 ? shadowColor : atten < 1 ? midColor : color;
    #endif
#else
    color = GetRampMap(factor);
    #endif
    return color;
}

float3 ShadeAmbient(ToonSurfaceData surface, Light light)
{
    MixRealtimeAndBakedGI(light, surface.normalWS, surface.bakedGI, half4(0, 0, 0, 0));
    half3 ambient = surface.bakedGI * GetIntensityGI();
    return ambient;
}
float3 ShadeDiffuse(ToonSurfaceData surface, Light light)
{
    float2 factor = GetRampFactor(surface, light);
    float3 rampColor = GetRampColor(factor,light);
    float3 diffuse = light.color * rampColor;
    return diffuse;
}
float3 ShadeSpecular(ToonSurfaceData surface, Light light)
{
    return float3(0, 0, 0);
}

float3 ShadeRimLight(ToonSurfaceData surface, Light light)
{

    float3 normal = surface.normalWS;
    float2 N_view = normalize(TransformWorldToViewDir(normal).xy);
    float originDepth = GetDepthTexture(surface.screenUV);
    float depth = LinearEyeDepth(originDepth, _ZBufferParams);

    float3 rim = float3(0.0, 0.0, 0.0);

    float3 L = light.direction;
    //float3 V = _WorldSpaceCameraPos - inputs.positionWS;
    float2 L_view = normalize(TransformWorldToViewDir(L).xy);
    float NdotL = dot(N_view, L_view) + _RimLength;
    float scale = (NdotL + 1) / 2 * _RimWidth * 0.01;
    //* DepthAttenuation(depth)
    float2 uv = clamp(surface.screenUV + N_view * scale,
        0, _ScreenParams.xy / _ScreenParams.y);
    float originDepth1 = GetDepthTexture(uv);
    float depth1 = LinearEyeDepth(originDepth1, _ZBufferParams);
    float depthDiff = depth1 - depth;
    float intensity = smoothstep(0.24 * _RimFeather * depth, 0.25 * depth, depthDiff);

    rim = _RimColor.rgb * intensity * light.color;
    //rim = float3(depthDiff,0, 0);
    
    //float depth, depth1;
    //float3 normal, normal1;
    ////DecodeDepthNormal(depthNormal, depth, normal);
    //return float4(depthNormal.r, 1);

    return rim;
}

float4 GetToonLighting(ToonSurfaceData surface)
{
    float3 finalColor = 0.0;
    
    #ifdef _RECEIVE_SHADOWS
    Light light = GetMainLight(surface.shadowCoord);
    #else
    Light light = GetMainLight();
    #endif
    float3 ambient = ShadeAmbient(surface, light);
    float3 diffuse = ShadeDiffuse(surface, light);
    float3 specular = ShadeSpecular(surface, light);
    float3 rim = ShadeRimLight(surface, light);

    finalColor = (ambient + diffuse) * surface.baseColor + specular + rim;
    return float4(finalColor, surface.alpha);
}


#endif