#version 430
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 VertexColor; 
out vec2 TexCoord; 

// https://learnopengl.com/Getting-started/Shaders

void main() {
    gl_Position = vec4(aPos, 1.0);
    VertexColor = aColor;
    TexCoord = aTexCoord;
}