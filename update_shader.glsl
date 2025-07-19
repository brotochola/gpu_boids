#version 300 es
in vec4 aPosition;

uniform float uSeparation;
uniform float uAlignment;
uniform float uCohesion;
uniform float uMaxSpeed;
uniform float uMaxForce;
uniform float uSeparationRadius;
uniform float uAlignmentRadius;
uniform float uCohesionRadius;
uniform float uCanvasWidth;
uniform float uCanvasHeight;
uniform float uDeltaTime;
uniform int uNumBoids;
uniform sampler2D uBoidTexture;
uniform vec2 uTextureSize;

out vec4 vNewPosition;

vec4 getBoidData(int index) {
    int x = index % int(uTextureSize.x);
    int y = index / int(uTextureSize.x);
    return texelFetch(uBoidTexture, ivec2(x, y), 0);
}

void main() {
    int currentIndex = gl_VertexID;
    vec2 pos = aPosition.xy;
    vec2 vel = aPosition.zw;

    vec2 separation = vec2(0.0f);
    vec2 alignment = vec2(0.0f);
    vec2 cohesion = vec2(0.0f);

    int separationCount = 0;
    int alignmentCount = 0;
    int cohesionCount = 0;

    for(int i = 0; i < uNumBoids; i++) {
        if(i == currentIndex)
            continue;

        vec4 otherBoid = getBoidData(i);
        vec2 otherPos = otherBoid.xy;
        vec2 otherVel = otherBoid.zw;

        vec2 diff = pos - otherPos;
        float dist = length(diff);

        if(dist > 0.0f && dist < uSeparationRadius) {
            separation += normalize(diff) / dist;
            separationCount++;
        }

        if(dist > 0.0f && dist < uAlignmentRadius) {
            alignment += otherVel;
            alignmentCount++;
        }

        if(dist > 0.0f && dist < uCohesionRadius) {
            cohesion += otherPos;
            cohesionCount++;
        }
    }

    vec2 acceleration = vec2(0.0f);

    if(separationCount > 0) {
        separation /= float(separationCount);
        if(length(separation) > 0.0f) {
            separation = normalize(separation) * uMaxSpeed - vel;
            acceleration += separation * uSeparation;
        }
    }

    if(alignmentCount > 0) {
        alignment /= float(alignmentCount);
        if(length(alignment) > 0.0f) {
            alignment = normalize(alignment) * uMaxSpeed - vel;
            acceleration += alignment * uAlignment;
        }
    }

    if(cohesionCount > 0) {
        cohesion /= float(cohesionCount);
        cohesion = cohesion - pos;
        if(length(cohesion) > 0.0f) {
            cohesion = normalize(cohesion) * uMaxSpeed - vel;
            acceleration += cohesion * uCohesion;
        }
    }

    // Limit acceleration
    float maxForce = uMaxForce;
    if(length(acceleration) > maxForce) {
        acceleration = normalize(acceleration) * maxForce;
    }

    vel += acceleration * uDeltaTime;
    if(length(vel) > uMaxSpeed) {
        vel = normalize(vel) * uMaxSpeed;
    }

    pos += vel * uDeltaTime;

    if(pos.x < 0.0f)
        pos.x = uCanvasWidth;
    if(pos.x > uCanvasWidth)
        pos.x = 0.0f;
    if(pos.y < 0.0f)
        pos.y = uCanvasHeight;
    if(pos.y > uCanvasHeight)
        pos.y = 0.0f;

    vNewPosition = vec4(pos, vel);
}