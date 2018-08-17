// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Book/C7_RampTexShader" {
	Properties {
		_Color("Color Tint", Color) = (1,1,1,1)
		_Ramptex("Ramp Tex", 2D) = "white"{}
		_Specular("Specular",COLOR) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 32
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _Ramptex;
			float4 _Ramptex_ST;
			fixed4 _Specular;
			float _Gloss;	

			struct a2v{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
			float4 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
			};
		
			v2f vert(a2v v):POSITION
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord,_Ramptex);
				return o;
			}

			fixed4 frag(v2f i):SV_TARGET0
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;
				fixed3 diffuseColor = tex2D(_Ramptex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(halfDir, worldNormal),0.0),_Gloss);
				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
