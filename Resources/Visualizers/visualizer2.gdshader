/*
	スペクトラム表示シェーダー by あるる（きのもと 結衣） @arlez80;
	initial Spectrum Displaying Shader by KINOMOTO Yui;
	shader enhanced by @xShader1374_.
	MIT License
*/
shader_type canvas_item;
render_mode unshaded;

uniform float columns[16];
uniform int columnsAmount = 15;
uniform sampler2D color : filter_linear_mipmap_anisotropic;

void fragment( )
{
	float p = UV.x * float(columnsAmount);
	float f = mix( columns[0], columns[1], clamp( p, 0.0, 1.0 ) );

	for(int i = 1; i < columnsAmount; i++){
		f = mix( f, columns[1+i], clamp( p - float(i), 0.0, 1.0 ) );
	}

	COLOR = texture( color, vec2( UV.x, 0.0 ) ) * float( 1.0 - UV.y < f );

}