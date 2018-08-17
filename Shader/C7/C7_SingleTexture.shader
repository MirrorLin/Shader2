// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/C7_SingleTexture" {
	Properties {
		_Color ("Color Tint", COLOR) = (1,1,1,1)
		_MainTex("MainTex",2D) = "Write"{}
		_Specular("Specular",COLOR) = (1,1,1,1)
		_Gloss("Gloss",Range(20,256)) = 20
	}
	SubShader {
		
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Specular;
				fixed _Gloss;


				struct a2v{
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
				};

				struct v2f{
					float4 pos:POSITION;
					float3 worldNormal:TEXCOORD0;
					float3 worldPos:TEXCOORD1;
					float2 uv:TEXCOORD2;
				};

				v2f vert(a2v v):POSITION
				{
					v2f o;
					o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz; 
					o.pos = UnityObjectToClipPos(v.vertex); 
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}

				fixed4 frag(v2f i):SV_TARGET0
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					
					fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = albedo * (dot(worldLightDir,worldNormal) * 0.5 + 0.5);

					//fixed3 reflectdir = reflect(-worldLightDir,worldNormal);
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 halfDir = normalize(worldLightDir + viewDir);
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(worldNormal,halfDir),0.0),_Gloss);

					return fixed4((ambient + diffuse + specular),1.0);
				}				
			ENDCG
		
		}
	}
	FallBack "Diffuse"
}
