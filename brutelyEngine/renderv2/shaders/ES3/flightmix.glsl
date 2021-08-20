#version 300 es

precision highp float;

in vec2 tpos;
out vec4 fragColour;

uniform sampler2D OBUF;
uniform sampler2D LIGHT;

void main()
{
    fragColour = texture(OBUF, tpos) + (texture(LIGHT, tpos));
    //fragColour = vec4(tpos.x, tpos.y, 0.0, 1.0);
}