#version 300 es

precision highp float;

uniform vec4 modelTint;

in vec3 normal;
in vec3 fpos;
in vec2 tpos;

uniform sampler2D colourTex;

out vec4 fragColour;

void main()
{
    vec4 texResult = texture(colourTex, tpos);
    vec4 mt = modelTint;
    fragColour = mix(mt, texResult, 0.3);
}
