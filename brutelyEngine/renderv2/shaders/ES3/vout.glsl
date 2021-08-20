#version 300 es

precision highp float;

layout (location = 0) in vec3 inpos;
layout (location = 1) in vec2 intexpos;

out vec2 tpos;

void main()
{
    gl_Position = vec4(inpos.x, inpos.y, 0.0, 1.0);
    tpos = intexpos;
}