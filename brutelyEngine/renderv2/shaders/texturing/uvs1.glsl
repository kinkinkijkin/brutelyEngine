#version 120

attribute vec2 mUV;

varying vec2 texCoord;

void main()
{
    //This is a basic texturing passthrough shader. Some form of this is required for texturing.
    texCoord = mUV;
}
