#version 300 es
precision mediump float;
uniform vec4 modelTint;
uniform vec3 lD;

in vec3 fragPos;
in vec3 normal;

out vec4 FragColor;

void main()
{
    float ambientStrength = 0.3;
    vec3 ambient = ambientStrength * modelTint.xyz;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lD - fragPos);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * normalize(modelTint.xyz + vec3(0.2, 0.2, 0.2));

    vec3 result = (diffuse + ambient);
    FragColor = vec4(result, modelTint.w);
//    FragColor = vec4(norm, 1.0);
}
