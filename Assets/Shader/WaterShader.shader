Shader "Custom/WaterShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Amplitude ("Amplitude", Range(0.0,10.0)) = 1.0
        _Steepness ("Steepness", Range(0.0,10.0)) = 1.0
        _Speed ("Speed", float) = 1.0
        _WaveLength ("WaveLength", float) = 10.0
        _Direction ("Direction (2D)", vector) = (1,0,0,0)
        
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
        };
        sampler2D _MainTex;
        fixed4 _Color;
        float2 _Direction;
        float _Amplitude, _Speed, _WaveLength, _Steepness;

        float3 GerstnerWave(float2 direction, float3 position, inout float3 tangent, inout float3 binormal)
        {
            float k = 2 * UNITY_PI / _WaveLength;
            float phaseSpeed = sqrt(9.8 / k);
            float2 dir = normalize(direction);
            float f = k * (dot(dir, position.xz) - phaseSpeed * _Time.y);
            float amplitude = _Steepness / k;
                        
            tangent += float3(-dir.x * dir.x * (_Steepness * sin(f)), dir.x * (_Steepness * cos(f)), -dir.x * dir.y * (_Steepness * sin(f)));
            binormal += float3(-dir.x * dir.y * (_Steepness * sin(f)), dir.y * (_Steepness * cos(f)), -dir.y * dir.y * (_Steepness * sin(f)));

            return float3(dir.x * (amplitude * cos(f)), amplitude * sin(f), dir.y * (amplitude * cos(f)));
        }
        
        void vert(inout appdata_full v)
        {
            float3 gridPoint = v.vertex.xyz;
            float3 binormal = float3(1,0,0);
            float3 tangent = float3(0,0,1);
            float3 p = gridPoint;
            p += GerstnerWave(_Direction, gridPoint, tangent, binormal);
            float3 normal = normalize(cross(binormal, tangent));
            v.vertex.xyz = p;
            v.normal = normal;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
