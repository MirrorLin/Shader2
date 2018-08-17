

Shader "Unity Shader Book/Simple Shader" {
	Properties
	{
		_Color ("Color Tint", COLOR ) = (1.0,1.0,1.0,1.0)
	}

	SubShader
	{
		Pass{
				CGPROGRAM
				fixed4 _Color;

				#pragma vertex vert
				#pragma fragment frag

				//定义一个结构体来定义顶点着色器的输入
				struct a2v
				{
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
				};

				//定义一个结构体来定义顶点着色器的输出
				struct v2f
				{
					float4 pos: POSITION;
					float3 color:COLOR0;
				};
				
				v2f vert(a2v v):POSITION
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
					return o;
				}

				fixed4 frag(v2f i):SV_TARGET0
				{
					fixed3 c = i.color;
					c *= _Color.rgb;
					return fixed4(c,1.0);
				}
				ENDCG
			}
	}
}
