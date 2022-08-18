Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Normal ("Normal", 2D) = "white" {}
        _Direction1 ("Direction1", vector) = (0,0,0,0)
        _Amplitude ("Amplitude", float) = 1
        _Speed ("Speed", float) = 1
        _WaveLength ("WaveLength", float) = 1
        _NumWaves ("NumWaves", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Normal;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldPos;
        };

        float3 _Direction1;
        
        float _Amplitude;
        float _Speed;
        float _WaveLength;
        float _NumWaves;
        
        fixed4 _Color;
        float3 GerstnerWaves(float3 WorldPos, float3 WaterDirection, float WaveLength, float Speed, float Amplitude)
        {
             float w = 2 / WaveLength;
             float multiplier = w * Speed * _Time;
             float2 pos = float2(WorldPos.x, WorldPos.z);
             float dir = dot(normalize(WaterDirection.xy), pos);
             float result = (dir * w);
             result += multiplier;
             float amplitude = sin(result) * Amplitude;
             
             float y = amplitude;
             return float3(pos.x,y,pos.y);
        }
        
        void vert(inout appdata_full vertexData)
        {
            float3 wpos = vertexData.vertex.xyz;
            wpos += GerstnerWaves(wpos, _Direction1, _WaveLength, _Speed, _Amplitude);
            vertexData.vertex.xyz = wpos;
        }
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 n = tex2D (_Normal, IN.uv_BumpMap) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_BumpMap));
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
