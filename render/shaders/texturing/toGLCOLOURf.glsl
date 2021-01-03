#version 120

uniform sampler2D tex;

varying vec2 texCoord;

void main()
{
    //Simplest texturing fragment shader possible.
    gl_FragColor = texture(tex, texCoord);
}
