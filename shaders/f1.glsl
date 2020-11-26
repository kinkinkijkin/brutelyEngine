#version 300 es
precision mediump float;
smooth in vec4 vcolour;

out vec4 FragColor;

void main()
{
    FragColor = vcolour;
}
