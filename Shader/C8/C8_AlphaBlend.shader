Shader "Unity Shader Book/C8_AlphaBlend" {
	Properties {
		_Color("Color Tint",COLOR) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_AlphaScale("Alpha Scale", Range(0,1)) = 1
	}
	SubShader {
		Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass
		{
			ZWrite On
			ColorMask 0
		}
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			ZWrite Off
			Cull Back
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _AlphaScale;

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
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}

				fixed4 frag(v2f i):SV_TARGET0
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed4 texColor = tex2D(_MainTex,i.uv);
					//ALpha Test
					//clip(texColor.a - _Cutoff);

					fixed3 albedo = texColor.rgb * _Color.rgb;

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = albedo * _LightColor0.rgb * max(dot(worldNormal,worldLightDir),0.0);

					//fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);

					//fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(halfDir, tangentNormal),0.0),_Gloss);

					return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
				}

			ENDCG
		}
	}
	FallBack "Transparent/Cutout/VertexLit"
}
