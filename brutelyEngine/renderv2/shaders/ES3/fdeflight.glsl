#version 300 es

precision highp float;

uniform vec4 modelTint;

in vec3 lightpos;
in vec3 normal;
in vec3 fpos;
in vec2 tpos;

uniform sampler2D colourTex;

out vec4 fragColour;

void main()
{
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightpos);
    float distance = length(lightpos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * normalize(modelTint.xyz + vec3(0.2, 0.2, 0.2));

    fragColour = vec4(diffuse / distance, 1.0 / distance);
}