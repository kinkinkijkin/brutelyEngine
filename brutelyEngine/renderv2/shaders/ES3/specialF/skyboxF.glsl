#version 300 es

precision highp float;

uniform vec4 modelTint;
uniform vec3 lD;

in vec3 normal;
in vec3 fpos;
in vec2 tpos;

uniform sampler2D colourTex;

out vec4 fragColour;

void main()
{
	float ambientStrength = 0.9;
    vec3 ambient = ambientStrength * modelTint.xyz;

    vec4 texResult = texture(colourTex, tpos);
    fragColour = mix(vec4(ambient, modelTint.w), texResult, 0.4);
}
