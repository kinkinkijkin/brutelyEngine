import rendercore,initcore,glad/gl,objloader,datahelpers,nimgl/glfw,glm

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

var lightDir = vec3f(0.3, 0.5, -0.1)

var fscale = submitUniform(defprog, "frustumScale")
var znear = submitUniform(defprog, "zNear")
var zfar = submitUniform(defprog, "zFar")
var ldir = submitUniform(defprog, "lD")

setUniform1f(fscale, 1.0.GlFloat)
setUniform1f(znear, 0.05.GlFloat)
setUniform1f(zfar, 1000.0.GlFloat)
setUniform3fv(ldir, lightDir)

var toonProg = prepareES3program(@["shaders/v1.glsl"], @["shaders/specialF/toonLights.glsl"])
var toonWT = glGetUniformLocation(toonProg, "worldTransform")
var toonTT = glGetUniformLocation(toonprog, "modelTint")

var toonProgInd = submitProgram(toonProg, toonWT, toonTT)

var fscaleT = submitUniform(toonProg, "frustumScale")
var znearT = submitUniform(toonProg, "zNear")
var zfarT = submitUniform(toonProg, "zFar")
var ldirT = submitUniform(toonProg, "lD")

setUniform1f(fscaleT, 1.0.GlFloat)
setUniform1f(znearT, 0.05.GlFloat)
setUniform1f(zfarT, 1000.0.GlFloat)
setUniform3fv(ldirT, lightDir)

var triIndex = brutelyModelSubmit(triangleModel, "triangle")

var tmodIndex = brutelyModelSubmit(getOBJ("testassets/teapot.obj"), "test model")
var tmodCopy1 = brutelyModelDupe(tmodIndex, mat4(1.0.GlFloat), "copy1")

brutelyMoveDupe(triIndex, 0.uint, vec3f(1.0, 1.0, -5.0))
brutelyTintDupe(triIndex, 0.uint, vec4f(0.6, 0.3, 0.2, 0.3))

brutelyProgDupe(tmodIndex, 0.uint, toonProgInd)
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
