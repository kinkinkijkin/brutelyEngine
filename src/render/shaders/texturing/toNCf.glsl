#version 120

uniform sampler2D tex;

varying vec2 texCoord;

vec3 texColour;

void main()
{
    //Second simplest texturing shader possible.
    texColour = texture(tex, texCoord);
}
