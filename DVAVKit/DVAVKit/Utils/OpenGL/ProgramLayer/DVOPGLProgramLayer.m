//
//  DVOPGLProgramLayer.m
//  DVGLKit
//
//  Created by DV on 2019/1/15.
//  Copyright © 2019 DVKit. All rights reserved.
//

#import "DVOPGLProgramLayer.h"

@interface DVOPGLProgramLayer ()

@property(nonatomic, assign, readwrite) GLuint program;
@property(nonatomic, assign) GLuint verShader;
@property(nonatomic, assign) GLuint fragShader;

@end


@implementation DVOPGLProgramLayer

#pragma mark - <-- Initializer -->
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildProgram];
        [self checkProgramStatus];
        [self useProgram];
    }
    return self;
}

- (void)dealloc {
    if (_verShader) {
        glDeleteShader(_verShader);
        _verShader = 0;
    }
    if (_fragShader) {
        glDeleteShader(_fragShader);
        _fragShader = 0;
    }
    if (_program) {
        glUseProgram(0);
        glDeleteProgram(_program);
        _program = 0;
    }
}


#pragma mark - <-- Init -->
- (void)buildProgram {
    [self loadVertexShader];
    [self loadFragmentShader];
    
    _program = glCreateProgram();
    glAttachShader(_program, _verShader);
    glAttachShader(_program, _fragShader);
    glLinkProgram(_program);
    
    
    if (_verShader) {
        glDeleteShader(_verShader);
        _verShader = 0;
    }
    if (_fragShader) {
        glDeleteShader(_fragShader);
        _fragShader = 0;
    }
}

- (void)checkProgramStatus {
    //3.调用 glGetProgramiv  lglGetProgramInfoLog 来检查是否有error，并输出信息。
    GLint status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status); // 判断是否编译成功
    if (status == GL_TRUE) return;
    
    #ifdef DEBUG
    GLint logLen;
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLen); // 获取错误信息
    if (logLen > 0) {
        GLchar *log = (GLchar *)malloc(logLen);
        glGetProgramInfoLog(_program, logLen, &logLen, log);
        NSString *errorLog = [NSString stringWithFormat:@"[DVOpenGL ERROR]: %s", log];
        free(log);
        NSAssert(NO, errorLog);
    }
    #endif
    
    glDeleteProgram(_program);
    _program = 0;
}

- (void)useProgram {
    if (_program) glUseProgram(self.program);
}


#pragma mark - <-- 加载shader程序 -->
- (void)loadVertexShader {
    NSString *shaderStr;
    if ([self respondsToSelector:@selector(vertexShaderBundleName)]) {
        NSString *bundleName = [self vertexShaderBundleName];
        shaderStr = [self loadShaderStrWithBundleName:bundleName];
    }
    else if ([self respondsToSelector:@selector(vertexShaderString)]) {
        shaderStr = [self vertexShaderString];
    }
    
    if (shaderStr && shaderStr.length > 0) {
        _verShader = [self createShaderWithType:GL_VERTEX_SHADER shaderString:shaderStr];
    } else {
        NSAssert(NO, @"[DVOpenGL ERROR]: vertex string is nil");
    }
    
    if (!_verShader) {
        NSAssert(NO, @"[DVOpenGL ERROR]: failed to load vertex shader");
    }
}

- (void)loadFragmentShader {
    NSString *shaderStr;
    if ([self respondsToSelector:@selector(fragmentShaderBundleName)]) {
        NSString *bundleName = [self fragmentShaderBundleName];
        shaderStr = [self loadShaderStrWithBundleName:bundleName];
    }
    else if ([self respondsToSelector:@selector(fragmentShaderString)]) {
        shaderStr = [self fragmentShaderString];
    }
    
    if (shaderStr && shaderStr.length > 0) {
        _fragShader = [self createShaderWithType:GL_FRAGMENT_SHADER shaderString:shaderStr];
    } else {
        NSAssert(NO, @"[DVOpenGL ERROR]: fragment string is nil");
    }
    
    if (!_fragShader) {
        NSAssert(NO, @"[DVOpenGL ERROR]: failed to load fragment shader");
    }
}

- (NSString *)loadShaderStrWithBundleName:(NSString *)bundleName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Frameworks/DVAVKit.framework/DVAVKitBundle"
                                                           ofType:@"bundle"];
    
    if (!bundlePath) {
        bundlePath = [[NSBundle mainBundle] pathForResource:@"DVAVKitBundle" ofType:@"bundle"];
    }
    
    NSString *filePath = [bundlePath stringByAppendingPathComponent:bundleName];
    
    NSError *error;
    NSString *shaderStr = [NSString stringWithContentsOfFile:filePath
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
    
    NSAssert(!error, error.localizedDescription);
    return shaderStr;
}

- (GLuint)createShaderWithType:(GLenum)type shaderString:(NSString *)shaderString {
    const GLchar *source = (GLchar *)shaderString.UTF8String;
    const GLint sourceLen = (GLint)shaderString.length;
    
    GLuint shader = glCreateShader(type); // 创建一个shader的容器句柄
    if (shader == 0 || shader == GL_INVALID_ENUM) {
        NSAssert(NO, @"[DVOpenGL ERROR]: failed to create shader");
        return 0;
    }
    
    glShaderSource(shader, 1, &source, &sourceLen); // 加载着色器程序
    glCompileShader(shader); // 编译着色器程序
    
    do {
        GLint status;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &status); // 判断是否编译成功
        if (status == GL_TRUE) break;
        
        #ifdef DEBUG
        GLint logLen;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLen); // 获取错误信息
        if (logLen > 0) {
            GLchar *log = (GLchar *)malloc(logLen);
            glGetShaderInfoLog(shader, logLen, &logLen, log);
            NSString *errorLog = [NSString stringWithFormat:@"[DVOpenGL ERROR]: %s", log];
            free(log);
            NSAssert(NO, errorLog);
        }
        #endif
        
        glDeleteShader(shader);
        shader = 0;
    } while (NO);

    return shader;
}

@end
