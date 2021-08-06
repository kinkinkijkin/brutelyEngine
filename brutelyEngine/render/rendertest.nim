import rendercore,initcore,glad/gl,objloader,datahelpers,nimgl/glfw,glm,times,math

brutelySetup()

proc keyCheck(window:GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32): void {.cdecl.} =
    if key == GLFWKey.ESCAPE and action == GLFWPress:
        window.setWindowShouldClose(true)

discard wind.setKeyCallback(keyCheck)
wind.makeContextCurrent()

var tri: seq[GlFloat] = @[-3.0f, -3.0f, -0.5f,
                        3.0f, -3.0f, -0.5f,
                        0.0f, 3.0f, -0.5f]

var triuv: seq[GlFloat] = @[0.0f, 0.0f,
                            1.0f, 0.0f,
                            0.5f, 1.0f]

var triind: seq[GlUint] = @[0.GlUint, 1, 2]

var triangleModel: BrutelyModel

triangleModel.verts = tri
triangleModel.uvs = triuv
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

var toonProg = prepareES3program(@["shaders/ES3/vdefault.glsl"], @["shaders/ES3/specialF/toonLights.glsl"])

var toonProgInd = submitProgramEasy(toonProg)

var fscaleT = submitUniform(toonProg, "frustumScale")
var znearT = submitUniform(toonProg, "zNear")
var zfarT = submitUniform(toonProg, "zFar")
var ldirT = submitUniform(toonProg, "lD")

setUniform1f(fscaleT, 1.0.GlFloat)
setUniform1f(znearT, 0.05.GlFloat)
setUniform1f(zfarT, 1000.0.GlFloat)
setUniform3fv(ldirT, lightDir)

var skyboxProg = prepareES3program(@["shaders/ES3/specialV/skybox.glsl"], @["shaders/ES3/specialF/skyboxF.glsl"])

var skyboxProgInd = submitProgramEasy(skyboxProg)

var fscaleS = submitUniform(skyboxProg, "frustumScale")
var znearS = submitUniform(skyboxProg, "zNear")
var zfarS = submitUniform(skyboxProg, "zFar")

setUniform1f(fscaleS, 1.0.GlFloat)
setUniform1f(znearS, 0.05.GlFloat)
setUniform1f(zfarS, 7000.0.GlFloat)

var triIndex = brutelyModelSubmit(triangleModel, "triangle")
var triTexIndex = loadinTexture("testassets/logo.png")

var tmodIndex = brutelyModelSubmit(getOBJ("testassets/teapot.obj"), "test model")
var tmodCopy1 = brutelyModelDupe(tmodIndex, mat4(1.0.GlFloat), "copy1")

var skbIndex = brutelyModelSubmit(getOBJ("testassets/cube.obj"), "skybox")

brutelyMoveDupe(triIndex, 0.uint, vec3f(1.0, -3.0, -5.0))
brutelyTintDupe(triIndex, 0.uint, vec4f(0.6, 0.3, 0.2, 0.3))
brutelyDupeTexture(triIndex, 0.uint, triTexIndex)

brutelyProgDupe(tmodIndex, 0.uint, toonProgInd)
brutelyMoveDupe(tmodIndex, 0.uint, vec3f(1.0, 1.0, -10.0))
brutelyTintDupe(tmodIndex, 0.uint, vec4f(0.7, 0.4, 0.4, 1.0))

brutelyMoveDupe(tmodIndex, tmodCopy1, vec3f(-3.0, -2.0, -100.0))
brutelyTintDupe(tmodIndex, tmodCopy1, vec4f(0.4, 0.4, 0.4, 1.0))

brutelyProgDupe(skbIndex, 0.uint, skyboxProgInd)
brutelyMoveDupe(skbIndex, 0.uint, vec3f(0.1))
brutelyTintDupe(skbIndex, 0.uint, vec4f(0.14, 0.32, 0.55, 0.8))
brutelyDupeTexture(skbIndex, 0.uint, triTexIndex)

camMatr[3] += vec4f((vec3f(0.1, 0.1, 0.1)), 1)

var starttime = cpuTime()

var ftt: float = 0.0
while not wind.windowShouldClose:
    var frametimer = cpuTime()
    glfwPollEvents()
    echo brutelyDraw()
    var animtime = cpuTime() - starttime
    brutelyMoveDupe(tmodIndex, tmodCopy1, vec3f(sin(animtime * 33), cos(animtime * 32), sin(animtime * 20) * 3 - 20))
    brutelyRotateDupe(tmodIndex, tmodCopy1,  vec3f(0,1,0), 5 * ftt)
    brutelyRotateDupe(tmodIndex, 0,  vec3f(sin(animtime * 33), cos(animtime * 32), sin(animtime * 14)), 4 * ftt)
    camMatr.rotateInpl(60.0 * ftt, vec3f(0,0.9,0.1) )
    
    ftt = cpuTime() - frametimer

wind.destroyWindow()
glfwTerminate()
quit(0)
