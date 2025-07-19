#version 300 es
in vec4 aPosition;
in vec2 aVertex;
uniform mat4 uProjection;
layout(location = 2) in vec3 aColor;
out vec3 vColor;
void main() {
    vec2 pos = aPosition.xy;
    vec2 vel = aPosition.zw;

    vec2 dir = length(vel) > 0.0f ? normalize(vel) : vec2(1.0f, 0.0f);
    vec2 perp = vec2(-dir.y, dir.x);

    vec2 localPos = aVertex.x * dir * 8.0f + aVertex.y * perp * 4.0f;
    vec2 worldPos = pos + localPos;

    gl_Position = uProjection * vec4(worldPos, 0.0f, 1.0f);
    vColor = aColor;
}
