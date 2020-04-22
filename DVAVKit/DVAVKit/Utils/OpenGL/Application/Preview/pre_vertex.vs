attribute vec4 position;
attribute vec2 inTexcoord;
varying vec2 outTexcoord;
void main() {
    gl_Position = position;
    outTexcoord = inTexcoord;
}
