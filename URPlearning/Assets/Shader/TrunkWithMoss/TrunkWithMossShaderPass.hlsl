#ifndef TRUNK_WITH_MOSS_INCLUDED
#define TRUNK_WITH_MOSS_INCLUDED

#include "TrunkWithMossLighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float3 color      : COLOR;
    float2 uv         : TEXCOORD0;
    float2 lightmapUV : TEXCOORD1;
};


struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWS : VAR_NORMAL;
    float3 tangentWS : VAR_TANGENT;
    //float3 color : VAR_COLOR;
    float4 uv       : TEXCOORD0;
    float  layer : TEXCOORD1;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 3);
};


Attributes TrunkWithMossShaderPassVertex(Attributes input)
{
    return input;

}

void AppendShellVertex(inout TriangleStream<Varyings> stream, Attributes input, 
    int index)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
  
    float3 posWS = vertexInput.positionWS + normalInput.normalWS * (_ShellStep * index) * (1-input.color.r);
    float4 posCS = TransformWorldToHClip(posWS);
    
    output.positionCS = posCS;
    output.positionWS = posWS;
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    output.tangentWS = normalInput.tangentWS;
    output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);
    output.uv.zw = TRANSFORM_TEX(input.uv, _MossMap);

    output.layer = (float)index / _ShellAmount;
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    stream.Append(output);
}

[maxvertexcount(42)]
void TrunkWithMossShaderPassGeometry(triangle Attributes input[3], inout TriangleStream<Varyings> stream)
{
    int cnt = GetShellAmount();
    for (float i = 0; i < cnt; ++i)
    {
        
        for (float j = 0; j < 3; ++j)
        {
#ifdef _NORMALMAP
            if (i == 1)
            {
                float3 normalTS = GetNormalMapLOD(TRANSFORM_TEX(input[j].uv, _MossMap), 0);
                input[j].normalOS = NormalTangentToWorld(normalTS, input[j].normalOS, input[j].tangentOS);
              /*  float2 xi = Hammersley(input[j].uv.x * _ScreenParams.x + input[j].uv.y * _ScreenParams.y, _ScreenParams.x + _ScreenParams.y);
                input[j].normalOS = ImportanceSampleGGXDir(xi, input[j].normalOS, GetMossRoughness() * input[j].color.g);*/
            }
#endif
            AppendShellVertex(stream, input[j], i);
        }
        stream.RestartStrip();
        if (1-input[0].color.r < 0.00001 || 1-input[1].color.r < 0.00001 || 1-input[2].color.r < 0.00001)
            break;
    }
}

float4 TrunkWithMossShaderPassFragment(Varyings input) : SV_Target
{
    SurfaceData surface;
    float4 moss = GetMossMap(input.uv.zw);
    half alpha = moss.r * (1.0 - input.layer)* (1.0 - input.layer);
    half occlusion = lerp(1.0 - GetOcclusion(), 1.0, input.layer);
    surface.baseColor = input.layer > 0 ? 
        lerp(GetMossBaseColor(), GetMossHighColor(), input.layer) * occlusion :
        GetBaseColor() * GetBaseMap(input.uv.xy);
    if (input.layer > 0.0 && alpha < GetAlphaCutout()) discard;
    
#ifdef _ALPHATEST_ON
    clip(surface.baseColor.a - GetCutoff());
#endif

    surface.normal = input.normalWS;

    surface.position = input.positionWS;
    surface.smoothness = GetSmoothness();
    surface.specColor = GetMossHighColor();
    surface.viewDir = normalize(GetCameraPositionWS() - input.positionWS);
    surface.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    surface.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);
    surface.layer = input.layer;

    return GetLighting(surface);

}

#endif