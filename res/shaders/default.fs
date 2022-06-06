#version 430
out vec4 FragColor;

in vec3 VertexColor; 
in vec2 TexCoord; 

uniform sampler2D Texture0;
// uniform vec2 v_screenSize; // unpure

void main() {
    // float aspect = v_screenSize.x / v_screenSize.y; // unpure
    // vec2 uv = TexCoord;
    // uv.x *= aspect;
    // uv.x += (1.0 - aspect) / 2.0;
    // FragColor = texture(Texture0, uv) * vec4(VertexColor, 1.0);
    // til here
    FragColor = texture(Texture0, TexCoord) * vec4(VertexColor, 1.0);
} 