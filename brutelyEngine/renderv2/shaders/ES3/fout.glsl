#version 300 es

precision highp float;

in vec2 tpos;
out vec4 fragColour;

uniform sampler2D COLOUR;
uniform sampler2D LIGHTS;

void main()
{
    fragColour = mix(texture(COLOUR, tpos), (texture(LIGHTS, tpos) * 2.0), 0.7);
    //fragColour = vec4(tpos.x, tpos.y, 0.0, 1.0);
    //fragColour = texture(LIGHTS, tpos);
}