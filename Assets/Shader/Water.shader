Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
       [MainTexture] _MainTex ("Texture", 2D) = "white" {}
       [Normal] _Normal ("Normal", 2D) = "white" {}
        _Direction1 ("Direction1", vector) = (0,0,0,0)
        _Direction2 ("Direction2", vector) = (0,0,0,0)
        _Amplitude ("Amplitude", float) = 1
        _Speed ("Speed", float) = 1
        _WaveLength ("WaveLength", float) = 1
        _NumWaves ("NumWaves", float) = 1
        _Steepness ("Steepness", Range(0.0,10.0)) = 0.1
        _WaterUvMovement ("WaterUv Movement", vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows
        #pragma vertex vert Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0



        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldPos;
        };
        float4 _WaterUvMovement;

        float3 _Direction1;
        float3 _Direction2;
        
        float _Amplitude;
        float _Speed;
        float _WaveLength;
        float _NumWaves;
        float _Steepness;
        
        fixed4 _Color;
        float3 GerstnerWaves(float3 WorldPos, float3 WaterDirection, float WaveLength, float Speed, float Amplitude, float Steepness, float NumWaves)
        {
             float w = 2 / WaveLength;
             float multiplier = w * Speed * _Time;
             float2 pos = float2(WorldPos.x, WorldPos.z);
             float dir = dot(normalize(WaterDirection.xy), pos);
             float result = (dir * w);
             result += multiplier;
             float amplitude = sin(result) * Amplitude;
             float Qi = (Steepness / (w * amplitude * NumWaves));
            Qi *= amplitude;
             float y = amplitude;
            float x = cos(pos.x) * Qi;
            float z = cos(pos.y) * Qi;
            
             return float3(x,y,z);
        }
        
        void vert(inout appdata_full vertexData)
        {
            float3 wpos = vertexData.vertex.xyz;
            float3 waves1 =  GerstnerWaves(wpos, _Direction1, _WaveLength, _Speed, _Amplitude, _Steepness, _NumWaves);
            float3 waves2 =  GerstnerWaves(wpos, _Direction2, _WaveLength, _Speed, _Amplitude, _Steepness, _NumWaves);
            float3 negDir1 = _Direction1 * -1;
            float3 negDir2 = _Direction2 * -1;
            float3 waves3 =  GerstnerWaves(wpos, negDir1, _WaveLength * .5f, _Speed * .5f, _Amplitude * .5f, _Steepness, _NumWaves);
            float3 waves4 = GerstnerWaves(wpos, negDir2, _WaveLength * .5f, _Speed *.5f, _Amplitude * .5f, _Steepness, _NumWaves);
            float3 finalWave1 = waves1 + waves2;
            float3 finalWave2 = waves3 + waves4;
            wpos += finalWave1 + finalWave2;
            vertexData.vertex.xyz = wpos;
        }
        sampler2D _MainTex;
        sampler2D _Normal;
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            IN.uv_MainTex = IN.uv_MainTex * _WaterUvMovement.xy + (_WaterUvMovement.zw * _Time);
            IN.uv_BumpMap = IN.uv_BumpMap * _WaterUvMovement.xy + (_WaterUvMovement.zw * _Time);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D (_Normal, IN.uv_BumpMap));
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
