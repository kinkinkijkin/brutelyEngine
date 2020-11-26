import glad/gl,nimgl/glfw,glm,datahelpers,prgconf,strutils

proc compileVSh(vsName:string):GlUint =
    var vs: cstringArray
    var tvs: seq[string]

    for line in lines(vsName):
        tvs.add(line)
    vs = sourceToCSARRAY(tvs)

    var vshad = glCreateShader(GL_VERTEX_SHADER)
    glShaderSource(vshad, 1.GlInt, vs, nil)
    glCompileShader(vshad)

    var status: GlInt = 0

    glGetShaderiv(vshad, GL_COMPILE_STATUS, addr status)

    if status == GL_FALSE:
        echo "could not compile shader: " & vsName & "\n"
        var iloglen: GlInt = 0
        glGetShaderiv(vshad, GL_INFO_LOG_LENGTH, addr iloglen)

        var ilog: cstring = cast[ptr UncheckedArray[GlChar]](alloc0(iloglen))
        glGetShaderInfoLog(vshad, iloglen, nil, ilog)
        echo ilog
        quit(4)
    return vshad

proc compileFSh(fsName:string):GlUint =
    var fs: cstringArray
    var tfs: seq[string]

    for line in lines(fsName):
        tfs.add(line)
    fs = sourceToCSARRAY(tfs)

    var fshad = glCreateShader(GL_FRAGMENT_SHADER)
    glShaderSource(fshad, 1.GlInt, fs, nil)
    glCompileShader(fshad)

    var status: GlInt = 0

    glGetShaderiv(fshad, GL_COMPILE_STATUS, addr status)

    if status == GL_FALSE:
        echo "could not compile shader: " & fsName & "\n"
        var iloglen: GlInt = 0
        glGetShaderiv(fshad, GL_INFO_LOG_LENGTH, addr iloglen)

        var ilog: cstring = cast[ptr UncheckedArray[GlChar]](alloc0(iloglen))
        glGetShaderInfoLog(fshad, iloglen, nil, ilog)
        echo ilog
        quit(4)
    return fshad



proc prepareES3program*(vsNames, fsNames: seq[string]): GLuint =
    var prog = glCreateProgram()

    for shader in vsNames:
        prog.glAttachShader(compileVSh(shader))

    for shader in fsNames:
        prog.glAttachShader(compileFSh(shader))

    prog.glLinkProgram()

    glUseProgram(prog)

    return prog

#returns true on success
proc brutelyStart*(): bool =
    var success: bool = false
    try:
        assert glfwInit()
        if WNDRSIZ:
            glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE)
        else:
            glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE)
        wind = glfwCreateWindow(WNDSIZE[0].int32, WNDSIZE[1].int32, WNDNAME)
        wind.makeContextCurrent()
        glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API)
        discard gladLoadGLES2(glfwGetProcAddress)
        glfwSwapInterval(1)
        glViewport(0,0, WNDSIZE[0].GlSizei, WNDSIZE[1].GlSizei)
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f)


        glEnable(GL_DEPTH_TEST)
        glDepthFunc(GL_LEQUAL)
        glDepthMask(GL_TRUE.GlBoolean)

        glEnable(GL_CULL_FACE)
        glCullFace(GL_FRONT)
        glFrontFace(GL_CW)
        success = true
    finally:
        return success

#more to come as more init needed.