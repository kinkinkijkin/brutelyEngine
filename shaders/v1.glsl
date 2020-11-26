#version 300 es
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 innormal;

uniform float zNear;
uniform float zFar;
uniform float frustumScale;
uniform mat4 worldTransform;

smooth out vec3 normal;
out vec3 fragPos;

void main()
{
    vec4 cameraPos = vec4(position, 0.0) + worldTransform[3];
    vec4 clipPos;

    clipPos.xy = cameraPos.xy * frustumScale;

    clipPos.z = cameraPos.z * (zNear + zFar) / (zNear - zFar);
    clipPos.z += 2.0 * zNear * zFar / (zNear - zFar);

    clipPos.w = -cameraPos.z;

    gl_Position = clipPos;
    fragPos = vec3(worldTransform[3] * vec4(position, 1.0));
    normal = innormal;
}
