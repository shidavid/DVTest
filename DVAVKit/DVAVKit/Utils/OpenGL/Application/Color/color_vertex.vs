attribute vec4 position;
attribute vec4 inColor;
varying vec4 outColor;
void main() {
    gl_Position=position;
    outColor=inColor;
}
