module terramatter.render.renderengine;

import std.stdio;

import derelict.opengl3.gl3;

class RenderEngine {
    
    public static const (char*) getOpenGLVersion()	{
		return glGetString(GL_VERSION);
	}
}