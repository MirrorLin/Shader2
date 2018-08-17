Shader "Unity Shader Book/C8_AlphaTest" {
	Properties {
		_Color("Color Tint",COLOR) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_Cutoff ("Alpha CutOff", Range(0,1)) = 0.5
	}
	SubShader {
		Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			Cull Off
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _Cutoff;

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
					clip(texColor.a - _Cutoff);

					fixed3 albedo = texColor.rgb * _Color.rgb;

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = albedo * _LightColor0.rgb * max(dot(worldNormal,worldLightDir),0.0);

					//fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);

					//fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(halfDir, tangentNormal),0.0),_Gloss);

					return fixed4(ambient + diffuse, 1.0);
				}

			ENDCG
		}
	}
	FallBack "Transparent/Cutout/VertexLit"
}
