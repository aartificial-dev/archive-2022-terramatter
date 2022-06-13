module terramatter.core.resources.shader;

import std.string: toStringz;
import std.conv;
import std.stdio: writefln;

import bindbc.opengl;

import terramatter.core.os.filesystem;
import dlib.math.vector;
import dlib.math.matrix;
import terramatter.core.math.color;

final class Shader {
    private uint _vertex;
    private uint _fragment;

    private uint _program;

    private bool _isLinked = false;

    public static Shader _defaultShader = null;

    this(string vertexPath, string fragmentPath) {
        
        string v = readFile(vertexPath);
        string f = readFile(fragmentPath);
        
        writefln("Loaded vertex shader from '%s'.", vertexPath);
        writefln("Loaded fragment shader from '%s'.", fragmentPath);

        linkFromString(v, f);
    }

    // TODO
    // LINK https://learnopengl.com/code_viewer_gh.php?code=includes/learnopengl/shader.h

    public void linkFromString(string vertex, string fragment) {
        int success;
        
        _vertex = compileShader(vertex, GL_VERTEX_SHADER);
        glGetShaderiv(_vertex, GL_COMPILE_STATUS, &success);
        if (!success) throwShaderCompileError(_vertex);

        writefln("Vertex shader '%d' compiled successfully.", _vertex);

        _fragment = compileShader(fragment, GL_FRAGMENT_SHADER);
        glGetShaderiv(_fragment, GL_COMPILE_STATUS, &success);
        if (!success) throwShaderCompileError(_fragment);

        writefln("Fragment shader '%d' compiled successfully.", _fragment);

        _program = glCreateProgram();
        glAttachShader(_program, _vertex);
        glAttachShader(_program, _fragment);
        glLinkProgram(_program);

        glGetProgramiv(_program, GL_LINK_STATUS, &success);
        if (!success) throwProgramLinkError(_program);
        
        writefln("Shader program '%d' linked successfully.", _vertex);
        
        glDeleteShader(_vertex);
        glDeleteShader(_fragment);

        writefln("");

        _isLinked = true;
    }

    private void throwShaderCompileError(uint shader) {
        char[512] infoLog;
        int len;
        glGetShaderInfoLog(shader, 512, &len, infoLog.ptr);
        writefln("ERROR: Shader compilation failed.\n", infoLog);
        throw new Error("Shader compilation fail.");
    }

    private void throwProgramLinkError(uint program) {
        char[512] infoLog;
        int len;
        glGetProgramInfoLog(program, 512, &len, infoLog.ptr);
        writefln("ERROR: Shader program linking failed.\n", infoLog);
        throw new Error("Shader program linking fail.");
    }

    private uint compileShader(string source, GLenum type) {
        auto f = source.toStringz;
        const int fv = source.length.to!int;

        uint sh = glCreateShader(type);
        glShaderSource(sh, 1, &f, &fv);
        glCompileShader(sh);

        return sh;
    }

    public uint getUniformLocation(string name) {
        if (!checkIsLinked) return 0;
        return glGetUniformLocation(_program, name.toStringz);
    }

    public void set() {
        if (!checkIsLinked) return;
        
        glUseProgram(_program);
    }

    public void reset() {
        glUseProgram(0);
    }

    public uint program() {
        if (!checkIsLinked) return 0;
        return _program;
    }

    public void dispose() {
        if (!checkIsLinked) return;
        glDeleteProgram(_program);
    }

    public bool checkIsLinked() {
        if (!_isLinked) {
            writefln("Failed to use shader program. Shader '%d' is not linked", _program);
            return false;
        }
        return true;
    }

    public static Shader defaultShader() {
        if (_defaultShader is null) {
            _defaultShader = new Shader("res/shaders/default.vs", "res/shaders/default.fs");
        }
        return _defaultShader;
    }

    public void setBool(string name, bool value) {
        glUniform1i(getUniformLocation(name), value.to!int);
    }

    public void setInt(string name, int value) {
        glUniform1i(getUniformLocation(name), value);
    }

    public void setFloat(string name, float value) {
        glUniform1f(getUniformLocation(name), value);
    }
    
    public void setVec2(string name, Vector2f value) {
        glUniform2fv(getUniformLocation(name), 1, value.arrayof.ptr);
    }

    public void setVec2(string name, float x, float y) {
        glUniform2f(getUniformLocation(name), x, y);
    }

    public void setVec3(string name, Vector3f value) {
        glUniform3fv(getUniformLocation(name), 1, value.arrayof.ptr);
    }

    public void setVec3(string name, float x, float y, float z) {
        glUniform3f(getUniformLocation(name), x, y, z);
    }

    public void setVec4(string name, Vector4f value) {
        glUniform4fv(getUniformLocation(name), 1, value.arrayof.ptr);
    }

    public void setVec4(string name, float x, float y, float z, float w) {
        glUniform4f(getUniformLocation(name), x, y, z, w);
    }

    public void setCol(string name, Color value) {
        glUniform4fv(getUniformLocation(name), 1, value.arrayof.ptr);
    }

    public void setCol(string name, float r, float g, float b, float a) {
        glUniform4f(getUniformLocation(name), r, g, b, a);
    }

    // public void setMat2(string name, Matrix2f value) {
    //     glUniformMatrix2fv(getUniformLocation(name), 1, GL_FALSE, value.asArray1D.ptr);
    // }

    // public void setMat3(string name, Matrix3 value) {
    //     glUniformMatrix3fv(getUniformLocation(name), 1, GL_FALSE, value.asArray1D.ptr);
    // }

    public void setMat4(string name, Matrix4f value) {
        glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, value.arrayof.ptr);
        // glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, value.getM[0].ptr);
    }

    public void setDrawMode(DrawMode mode) {
        setInt("uDrawMode", mode);
    }

    public static enum DrawMode {
        normal, black, normalMap, depth
    }
}