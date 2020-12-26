import rendercore,glad/gl,objloader,datahelpers,nimgl/glfw,glm

brutelySetup()

proc keyCheck(window:GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
    if key == GLFWKey.ESCAPE and action == GLFWPress:
        window.setWindowShouldClose(true)

discard wind.setKeyCallback(keyCheck)
wind.makeContextCurrent()

var tri: seq[GlFloat] = @[-3.0f, -3.0f, -0.5f,
                        3.0f, -3.0f, -0.5f,
                        0.0f, 3.0f, -0.5f]

var triind: seq[GlUint] = @[0.GlUint, 1, 2]

var triangleModel: BrutelyModel

triangleModel.verts = tri
triangleModel.indices = triind

var fscale = submitUniform(prog, "frustumScale")
var znear = submitUniform(prog, "zNear")
var zfar = submitUniform(prog, "zFar")
var ldir = submitUniform(prog, "lD")

setUniform1f(fscale, 1.0.GlFloat)
setUniform1f(znear, 0.05.GlFloat)
setUniform1f(zfar, 1000.0.GlFloat)
setUniform3fv(ldir, vec3f(0.3, 0.5, -0.1))

submitWTLoc(glGetUniformLocation(prog, "worldTransform"))

var triIndex = brutelyModelSubmit(triangleModel, "triangle")

var tmodIndex = brutelyModelSubmit(getOBJ("testassets/teapot.obj"), "test model")
var tmodCopy1 = brutelyModelDupe(tmodIndex, mat4(1.0.GlFloat), "copy1")

brutelyMoveDupe(triIndex, 0.uint, vec3f(1.0, 1.0, -5.0))
brutelyTintDupe(triIndex, 0.uint, vec4f(0.6, 0.3, 0.2, 0.3))

brutelyMoveDupe(tmodIndex, 0.uint, vec3f(1.0, 1.0, -10.0))
brutelyTintDupe(tmodIndex, 0.uint, vec4f(0.7, 0.4, 0.4, 1.0))

brutelyMoveDupe(tmodIndex, tmodCopy1, vec3f(-3.0, -2.0, -100.0))
brutelyTintDupe(tmodIndex, tmodCopy1, vec4f(0.4, 0.4, 0.4, 1.0))

while not wind.windowShouldClose:
    glfwPollEvents()
    echo brutelyDraw()

wind.destroyWindow()
glfwTerminate()
quit(0)
