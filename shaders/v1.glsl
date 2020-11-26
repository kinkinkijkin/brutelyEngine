#version 300 es
layout (location = 0) in vec3 position;

uniform float zNear;
uniform float zFar;
uniform float frustumScale;
uniform mat4 worldTransform;

smooth out vec4 vcolour;

void main()
{
    vec4 cameraPos = vec4(position, 0.0) + worldTransform[3];
    vec4 clipPos;

    clipPos.xy = cameraPos.xy * frustumScale;

    clipPos.z = cameraPos.z * (zNear + zFar) / (zNear - zFar);
    clipPos.z += 2.0 * zNear * zFar / (zNear - zFar);

    clipPos.w = -cameraPos.z;

    vcolour = vec4(clipPos.x, clipPos.y, clipPos.z, 1.0);
    gl_Position = clipPos;
}
