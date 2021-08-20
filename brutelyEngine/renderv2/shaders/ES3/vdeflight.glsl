#version 300 es

precision highp float;

layout (location = 0) in vec3 inpos;
layout (location = 1) in vec2 intexpos;
layout (location = 2) in vec3 innormal;

uniform float zNear;
uniform float zFar;
uniform float frustumScale;
uniform mat4 worldTransform;
uniform vec3 lightWorld;

out vec3 fpos;
out vec3 normal;
out vec3 lightpos;

void main()
{
    vec3 inpos2 = inpos * mat3(worldTransform);
	//vec4 cameraPos = vec4(inpos2, 0) + worldTransform[3];
    vec4 cameraPos = -worldTransform * vec4(-inpos, 0) + worldTransform[3];
    vec4 clipPos;

    clipPos.xy = cameraPos.xy * frustumScale;

    clipPos.z = cameraPos.z * (zNear + zFar) / (zNear - zFar);
    clipPos.z += 2.0 * zNear * zFar / (zNear - zFar);

    clipPos.w = -cameraPos.z;
    vec3 fpos2 = vec3(-cameraPos);

    fpos = fpos2;
    lightpos = lightWorld - fpos2;

    gl_Position = clipPos;
    
    normal = vec3(-worldTransform * vec4(innormal, 0));
}
