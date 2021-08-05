#version 300 es

precision highp float;

layout (location = 0) in vec3 inpos;
layout (location = 1) in vec2 intexpos;
layout (location = 2) in vec3 innormal;

uniform float zNear;
uniform float zFar;
uniform float frustumScale;
uniform mat4 worldTransform;

out vec2 tpos;
out vec3 fpos;
out vec3 normal;

void main()
{
    vec3 inpos2 = inpos * 100.0;
	vec4 cameraPos = -worldTransform * vec4(inpos2, 0);
    vec4 clipPos;

    clipPos.xy = cameraPos.xy * frustumScale;

    clipPos.z = cameraPos.z * (zNear + zFar) / (zNear - zFar);
    clipPos.z += 2.0 * zNear * zFar / (zNear - zFar);

    clipPos.w = -cameraPos.z;
    fpos = inpos2 * 100.0;
    gl_Position = clipPos;
    
    normal = vec3(vec4(innormal, 0) * worldTransform);
    
    tpos = intexpos;
}
