// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/C6_SpecularVertex" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader {
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;
				
				struct a2v{
					fixed4 vertex:POSITION;
					fixed3 normal:NORMAL;
				};

				struct v2f{
					fixed4 pos:POSITION;
					fixed3 worldNormal:TEXCOORD0;
					fixed3 worldPos:TEXCOORD1;
				};

				v2f vert(a2v v):POSITION
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
					return o;
				}

				fixed4 frag(v2f i):SV_TARGET0
				{
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);
					
					fixed3 diffuse = _Diffuse * _LightColor0.rgb * (dot(worldLightDir, i.worldNormal) * 0.5 + 0.5);

					fixed3 reflectDir = normalize(reflect(-worldLightDir,i.worldNormal));
					fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

					fixed3 specular = _Specular * _LightColor0.rgb * pow(max(dot(viewDir,reflectDir),0.0),_Gloss);
					return fixed4(ambient + diffuse + specular,1.0);
				}
				
			ENDCG
		}
	}
	
	FallBack "Specular"
}
