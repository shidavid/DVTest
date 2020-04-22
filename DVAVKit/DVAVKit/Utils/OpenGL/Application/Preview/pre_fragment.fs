varying highp vec2 outTexcoord;
precision mediump float;
uniform sampler2D yTexture;
uniform sampler2D uvTexture;
uniform mediump mat3 colorMatrix;
void main(){
    mediump vec3 yuv;
    lowp vec3 rgb;
    yuv.x = texture2D(yTexture, outTexcoord).r;
    yuv.yz = texture2D(uvTexture, outTexcoord).ra - vec2(0.5, 0.5);
    rgb = colorMatrix * yuv;
    gl_FragColor = vec4(rgb, 1);
}

