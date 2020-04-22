precision highp float;
varying highp vec2 v_texcoord;
uniform sampler2D texSampler;
void main() {
    gl_FragColor = texture2D(texSampler,v_texcoord); 
}
 
