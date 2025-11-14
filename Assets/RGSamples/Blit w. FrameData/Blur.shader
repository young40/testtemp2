Shader "Hidden/FullScreen/Blur"
{
    Properties
    {
        _BlurSize("Blur Size", Range(0, 10)) = 1.0
    }
    SubShader
    {
        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            // ✅ 必须显式声明纹素尺寸变量
            float4 _BlitTexture_TexelSize; // xy = 1/width, 1/height, zw = width, height
            
            TEXTURE2D_X(_BlitTexture);
            SAMPLER(sampler_BlitTexture);
            float _BlurSize;

            struct Varyings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings Vert(uint vertexID : SV_VertexID)
            {
                Varyings output;
                output.pos = GetFullScreenTriangleVertexPosition(vertexID);
                output.uv = GetFullScreenTriangleTexCoord(vertexID);
                return output;
            }

            float4 Frag(Varyings input) : SV_Target
            {
                // 现在可以正常使用 _BlitTexture_TexelSize 了
                float2 offset = _BlurSize * _BlitTexture_TexelSize.xy;
                float4 color = 0;
                color += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.uv + float2(-offset.x, -offset.y));
                color += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.uv + float2( offset.x, -offset.y));
                color += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.uv + float2(-offset.x,  offset.y));
                color += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.uv + float2( offset.x,  offset.y));
                return color / 4.0;
            }
            ENDHLSL
        }
    }
}