Shader "Custom/WaterShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Normal ("Normal", 2D) = "bump" {}
        _Amplitude ("Amplitude", Range(0.0,10.0)) = 1.0
        _AmplitudeValue ("AmplitudeValue", Range(0.0,10.0)) = 1.0
        _Steepness ("Steepness", Range(0.0,10.0)) = 1.0
        _Speed ("Speed", float) = 1.0
        _WaveLength ("WaveLength", float) = 10.0
        _Direction ("Direction (2D)", vector) = (1,0,0,0)
        _Direction2 ("Direction2 (2D)", vector) = (0,1,0,0)
        _WaveA ("Wave A (dir, steepness, wavelength)", vector) = (1.0,0.0,0.25,10.0)
        _WaveB ("Wave B", vector) = (1.0,0.0,0.5,10.0)
        _WaveC ("Wave C", vector) = (1.0,0.0,0.5,10.0)
        _WaveD ("Wave D", vector) = (1.0,0.0,0.5,10.0)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        #pragma target 4.0
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };
        sampler2D _MainTex, _Normal;
        fixed4 _Color;
        float4 _WaveA, _WaveB, _WaveC, _WaveD;
        float2 _Direction, _Direction2;
        float _Amplitude, _Speed, _WaveLength, _Steepness,_AmplitudeValue;

        float3 GerstnerWave(float4 Wave, float3 position, inout float3 tangent, inout float3 binormal)
        {
            float steepness = Wave.z;
            float waveLength = Wave.w;
            float k = 2 * UNITY_PI / waveLength;
            float phaseSpeed = sqrt(9.8 / k);
            float2 dir = normalize(Wave.xy);
            float f = k * (dot(dir, position.xz) - phaseSpeed * _Time.y);
            float amplitude = steepness / k;
            tangent += float3(1-dir.x * dir.x * (steepness * sin(f)), dir.x * (steepness * cos(f)), -dir.x * dir.y * (steepness * sin(f)));
            binormal += float3(-dir.x * dir.y * (steepness * sin(f)), dir.y * (steepness * cos(f)),1 -dir.y * dir.y * (steepness * sin(f)));

            return float3(dir.x * (amplitude * cos(f)), amplitude * sin(f), dir.y * (amplitude * cos(f)));
        }
        
        void vert(inout appdata_full v)
        {
            float3 gridPoint = v.vertex.xyz;
            float3 binormal = float3(0,0,1);
            float3 tangent = float3(1,0,0);
            float3 p = gridPoint;
            p += GerstnerWave(_WaveA, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveB, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveC, gridPoint, tangent, binormal);
            p += GerstnerWave(_WaveD, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal, tangent));
            v.vertex.xyz = p;
            v.normal = normal;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 n = tex2D (_Normal, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = normalize(n.rgb);
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
