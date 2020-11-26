#version 300 es
precision mediump float;
uniform vec4 modelTint;
uniform vec3 lightDirection;

in vec3 fragPos;
smooth in vec3 normal;

out vec4 FragColor;

void main()
{
    float ambientStrength = 0.3;
    vec3 ambient = ambientStrength * modelTint.xyz;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightDirection - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * modelTint.xyz;

    vec3 result = (diffuse + ambient) * modelTint.xyz;
    FragColor = vec4(result, modelTint.w);
}
