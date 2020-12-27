#version 120
uniform vec4 modelTint;
uniform vec3 lD;

varying vec3 normal;
varying vec3 fpos;

void main()
{
    float ambientStrength = 0.3;
    vec3 ambient = ambientStrength * modelTint.xyz;

    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lD - fpos);

    float diff = max(dot(norm, lightDir), 0.0);

    if (diff > 0.93)
        diff = 1.0;
    else if (diff > 0.55)
        diff = 0.68;
    else if (diff > 0.25)
        diff = 0.27;
    else
        diff = diff * 0.9;

    vec3 diffuse = diff * normalize(modelTint.xyz + vec3(0.2, 0.2, 0.2));

    vec3 result = (diffuse + ambient);
    gl_FragColor = vec4(result, modelTint.w);
//    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
