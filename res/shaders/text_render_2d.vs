#version 430
layout (location = 0) in vec4 vertex; // <vec2 pos, vec2 tex>
out vec2 texcoords;

uniform mat4 m_projection;

void main() {
    gl_Position = m_projection * vec4(vertex.xy, 0.0, 1.0);
    
    texcoords = vertex.zw; // value is interpolated so it seems like UV
}  