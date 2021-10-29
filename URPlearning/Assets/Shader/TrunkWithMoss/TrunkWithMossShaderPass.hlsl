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
    float3 color : VAR_COLOR;
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

    float3 posWS = vertexInput.positionWS + normalInput.normalWS * (_ShellStep * index) * (1 - input.color.x);
    float4 posCS = TransformWorldToHClip(posWS);

    output.positionCS = posCS;
    output.positionWS = posWS;
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    output.color = input.color;
    output.uv.xy = TRANSFORM_TEX(input.uv, _BaseMap);

    output.layer = (float)index / _ShellAmount;
    output.uv.zw = TRANSFORM_TEX(input.uv, _MossMap);
    output.uv.zw += GetMossRoughness()
        * output.layer * 0.3 * Rand(output.uv.z + output.uv.w);

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    stream.Append(output);
}

[maxvertexcount(42)]
void TrunkWithMossShaderPassGeometry(triangle Attributes input[3], inout TriangleStream<Varyings> stream)
{

    int cnt = GetShellAmount();
    //cnt = max(1, cnt * (1 - 0.333*input[0].color.r - 0.333 * input[1].color.r - 0.333 * input[2].color.r));
    [loop] for (float i = 0; i < cnt; ++i)
    {
        [loop] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(stream, input[j], i);
        }
        stream.RestartStrip();
        if (1 - input[0].color.r < 0.00001 || 1 - input[1].color.r < 0.00001 || 1 - input[2].color.r < 0.00001)
            break;
    }
}

float4 TrunkWithMossShaderPassFragment(Varyings input) : SV_Target
{
    SurfaceData surface;
    surface.viewDir = normalize(GetCameraPositionWS() - input.positionWS);
    float mossClip = GetMossMap(input.uv.zw);
    half alpha = mossClip * (1.0 - input.layer) * (1.0 - input.layer);
    half occlusion = lerp(1.0 - GetOcclusion(), 1.0, input.layer);
    //surface.baseColor = input.layer > 0 ?
    //    occlusion * GetMossBaseMap(input.uv.zw) : GetBaseMap(input.uv.xy);
    surface.baseColor = lerp(GetBaseMap(input.uv.xy), occlusion * GetMossBaseMap(input.uv.zw),
        saturate((1-input.color.r) * _HeightScale * input.layer));
    if (input.layer > 0.0 && alpha < GetAlphaCutout()) discard;
  
#ifdef _ALPHATEST_ON
    clip(surface.baseColor.a - GetCutoff());
#endif
    surface.alpha = 1.0;
    //surface.litColor = input.layer > 0 ? GetMossBaseColor() : GetBaseColor();
    //surface.shadowColor = input.layer > 0 ? GetMossShadowColor() : GetShadowColor();
    surface.litColor = lerp(GetBaseColor(), GetMossBaseColor(),
        saturate((1 - input.color.r) * _HeightScale * input.layer));
    surface.shadowColor = lerp(GetShadowColor(), GetMossShadowColor(),
        saturate((1 - input.color.r) * _HeightScale * input.layer));
    surface.normal = input.normalWS;
    surface.color = input.color;
    surface.position = input.positionWS;
    surface.smoothness = GetSmoothness();
    surface.specColor = GetMossBaseColor();

    surface.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    surface.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);

    surface.layer = input.layer;

    return GetLighting(surface);

}

#endif