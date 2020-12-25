#version 120

uniform float zNear;
uniform float zFar;
uniform float frustumScale;
uniform mat4 worldTransform;

varying vec3 normal;
varying vec3 fpos;

void main()
{
    vec4 cameraPos = gl_Vertex + worldTransform[3];
    vec4 clipPos;

    clipPos.xy = cameraPos.xy * frustumScale;

    clipPos.z = cameraPos.z * (zNear + zFar) / (zNear - zFar);
    clipPos.z += 2.0 * zNear * zFar / (zNear - zFar);

    clipPos.w = -cameraPos.z;
    normal = gl_Normal;
    fpos = vec3(worldTransform[3] * gl_Vertex);
    gl_Position = clipPos;
}
