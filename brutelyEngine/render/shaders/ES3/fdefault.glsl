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
	float ambientStrength = 0.3;
    vec3 ambient = ambientStrength * modelTint.xyz;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lD - fpos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * normalize(modelTint.xyz + vec3(0.2, 0.2, 0.2));

    vec3 result = (diffuse + ambient);
    vec4 texResult = texture(colourTex, tpos);
    fragColour = mix(vec4(result, modelTint.w), texResult, 0.4);
}
