import goon,glm,glad/gl,nimgl/glfw,initcore,times,datahelpers,nimPNG,math,prgconf

var defprog: GlUint
var dprogwt, dprogco: GlInt
var lightProg: ShaderProg
var lightProgWorld: GlInt

var progSeq: seq[ShaderProg] = @[]
var drawSeq: seq[Drawable] = @[]
var unifSeq: seq[Glint] = @[]
var texSeq: seq[Gluint] = @[0.Gluint]
var lightSeq: seq[Light] = @[]

var shaderOut, shaderLightmix: GlUint
var shaderOutTex1, shaderOutTex2: GLint
var shaderLightmixTex1, shaderLightmixTex2: GlInt

var colFBO, ligFBO, colFBT, ligFBT, colFBT2, ligFBT2: GlUint
var ligmixFBO, ligmixFBO2, ligmixFBT, ligmixFBT2, ligmixFBT3, ligmixFBT4: GlUint

var outVAO: GlUint

var camMatr*: Mat4f = mat4f(1.0)



proc submitUniform*(program: GlUint, name: string): uint =
    var unif = glGetUniformLocation(program, name)
    unifSeq.add(unif)
    return (unifSeq.len - 1).uint

proc submitProgram*(program: GlUint, wt, tint: GlInt): uint =
    var tmpSP: ShaderProg
    tmpSP.loc = program
    tmpSP.wtloc = wt
    tmpSP.colloc = tint
    progSeq.add(tmpSP)
    return (progSeq.len - 1).uint

proc submitProgramEasy*(program:GlUint, WT, TINT: bool = true): uint =
    var worT, tit: GlInt
    if WT: worT = glGetUniformLocation(program, "worldTransform")
    if TINT: tit = glGetUniformLocation(program, "modelTint")
    return program.submitProgram(worT, tit)

proc loadinTexture*(filename: string): uint =
    #ONLY LOADS PNGS FOR NOW
    var loadedPNG: PNGResult[seq[uint8]]
    var res: PNGRes[seq[uint8]] = loadPNG(seq[uint8], filename, LCT_RGBA, 8)
    if res.isOk: loadedPNG = res.get()
    else: echo "texture oopsie"
    
    var tmpTexDest: Gluint = 0
    glGenTextures(1.GlSizei, addr tmpTexDest)
    glBindTexture(GL_TEXTURE_2D, tmpTexDest)
    
    
    #upcoming are defaults, configurability Coming Soon(tm)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT.Glint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT.Glint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST.Glint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST.Glint)
    
    var texData = seqToUncheckedArrayUINT8(loadedPNG.data)
    
    glTexImage2D(GL_TEXTURE_2D, 0.Glint, GL_RGBA.Glint, loadedPNG.width.Glsizei, loadedPNG.height.Glsizei, 0.Glint, GL_RGBA, GL_UNSIGNED_BYTE, texData)
    glGenerateMipmap(GL_TEXTURE_2D)
    
    glBindTexture(GL_TEXTURE_2D, 0)
    
    texSeq.add(tmpTexDest)
    return (texSeq.len - 1).uint

proc setUniform1f*(location: uint, value: float) =
    glUniform1f(unifSeq[location], value.GlFloat)

proc setUniform3fv*(location: uint, value: Vec3[GlFloat]) =
    glUniform3f(unifSeq[location], value.x, value.y, value.z)

proc setUniformM4fv*(location: uint, value: Mat4[GlFloat]) =
    var valueCopy = value
    glUniformMatrix4fv(unifSeq[location], 1, GL_FALSE.GlBoolean, addr valueCopy[0][0])

proc brutelySetup*() = #oh god this one ballooned
    assert brutelyStart()
    defprog = prepareES3program(@["shaders/ES3/vdefault.glsl"], @["shaders/ES3/fdefault.glsl"])
    dprogco = glGetUniformLocation(defprog, "modelTint")
    dprogwt = glGetUniformLocation(defprog, "worldTransform")

    glGenFramebuffers(1, addr colFBO)
    glBindFramebuffer(GL_FRAMEBUFFER, colFBO)

    glGenTextures(1, addr colFBT)
    glBindTexture(GL_TEXTURE_2D, colFBT)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_RGBA.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_RGBA, GL_UNSIGNED_BYTE, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colFBT, 0)

    glGenTextures(1, addr colFBT2)
    glBindTexture(GL_TEXTURE_2D, colFBT2)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_DEPTH24_STENCIL8.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, colFBT2, 0)

    if not (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE):
        echo "flat"

    #glUseProgram(0)

    lightProg.loc = prepareES3program(@["shaders/ES3/vdeflight.glsl"], @["shaders/ES3/fdeflight.glsl"])
    lightProgWorld = glGetUniformLocation(lightProg.loc, "lightWorld")
    lightProg.colloc = glGetUniformLocation(lightProg.loc, "modelTint")
    lightProg.wtloc = glGetUniformLocation(lightProg.loc, "worldTransform")

    glGenFramebuffers(1, addr ligFBO)
    glBindFramebuffer(GL_FRAMEBUFFER, ligFBO)

    glGenTextures(1, addr ligFBT)
    glBindTexture(GL_TEXTURE_2D, ligFBT)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_RGBA.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_RGBA, GL_UNSIGNED_BYTE, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, ligFBT, 0)

    glGenTextures(1, addr ligFBT2)
    glBindTexture(GL_TEXTURE_2D, ligFBT2)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_DEPTH24_STENCIL8.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, ligFBT2, 0)

    if not (glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE):
        echo "flat"

    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glBindTexture(GL_TEXTURE_2D, 0)

    shaderOut = prepareES3program(@["shaders/ES3/vout.glsl"], @["shaders/ES3/fout.glsl"])
    shaderOutTex1 = glGetUniformLocation(shaderOut, "COLOUR")
    shaderOutTex2 = glGetUniformLocation(shaderOut, "LIGHTS")

    var tmpVBO, tmpEBO, tmpTBO: GlUint

    glGenVertexArrays(1, addr outVAO)
    glGenBuffers(1, addr tmpVBO)
    glGenBuffers(1, addr tmpTBO)
    glGenBuffers(1, addr tmpEBO)

    glBindVertexArray(outVAO)

    var screen = seqToUncheckedArrayGLFLOAT(@[-1.0.GlFloat, -1.0, 0.0, -1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, -1.0, 0.0])
    var screenE = seqToUncheckedArrayGLUINT(@[0.GlUint, 1, 2, 0, 2, 3])
    var screenT = seqToUncheckedArrayGLFLOAT(@[0.0.GlFloat, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0])

    glBindBuffer(GL_ARRAY_BUFFER, tmpVBO)
    glBufferData(GL_ARRAY_BUFFER, (12 * sizeof(GlFloat)), screen, GL_STATIC_DRAW)
    glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE.GlBoolean, (3 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(0)
    
    glBindBuffer(GL_ARRAY_BUFFER, tmpTBO)
    glBufferData(GL_ARRAY_BUFFER, (8 * sizeof(GlFloat)), screenT, GL_STATIC_DRAW)
    glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE.GlBoolean, (2 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(1)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, tmpEBO)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, (6 * sizeof(Gluint)), screenE, GL_STATIC_DRAW)

    glUniform1i(shaderOutTex1, 0)
    glUniform1i(shaderOutTex2, 1)

    glBindVertexArray(0)

    glUseProgram(0)

    glGenFramebuffers(1, addr ligmixFBO)
    glBindFramebuffer(GL_FRAMEBUFFER, ligmixFBO)

    glGenTextures(1, addr ligmixFBT)
    glBindTexture(GL_TEXTURE_2D, ligmixFBT)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_RGBA.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_RGBA, GL_UNSIGNED_BYTE, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, ligmixFBT, 0)

    glGenTextures(1, addr ligmixFBT2)
    glBindTexture(GL_TEXTURE_2D, ligmixFBT2)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_DEPTH24_STENCIL8.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, ligmixFBT2, 0)

    glGenFramebuffers(1, addr ligmixFBO2)
    glBindFramebuffer(GL_FRAMEBUFFER, ligmixFBO2)

    glGenTextures(1, addr ligmixFBT3)
    glBindTexture(GL_TEXTURE_2D, ligmixFBT3)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_RGBA.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_RGBA, GL_UNSIGNED_BYTE, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, ligmixFBT3, 0)

    glGenTextures(1, addr ligmixFBT4)
    glBindTexture(GL_TEXTURE_2D, ligmixFBT4)
    glTexImage2D(GL_TEXTURE_2D, 0.GlInt, GL_DEPTH24_STENCIL8.GLint, WNDSIZE[0].GLsizei, WNDSIZE[1].GLsizei, 0.GlInt, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, nil)
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, ligmixFBT4, 0)

    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glBindTexture(GL_TEXTURE_2D, 0)

    shaderLightmix = prepareES3program(@["shaders/ES3/vout.glsl"], @["shaders/ES3/flightmix.glsl"])
    shaderLightmixTex1 = glGetUniformLocation(shaderLightmix, "OBUF")
    shaderLightmixTex2 = glGetUniformLocation(shaderLightmix, "LIGHT")

    glUniform1i(shaderLightmixTex1, 0)
    glUniform1i(shaderLightmixTex2, 1)

    glUseProgram(0)


proc dprogfrustum*(scale, zn, zf: GlFloat) =
    glUseProgram(defprog)
    var fscale = submitUniform(defprog, "frustumScale")
    var znear = submitUniform(defprog, "zNear")
    var zfar = submitUniform(defprog, "zFar")

    setUniform1f(fscale, scale)
    setUniform1f(znear, zn)
    setUniform1f(zfar, zf)

proc lprogfrustum*(scale, zn, zf: GlFloat) =
    glUseProgram(lightProg.loc)
    var fscale = submitUniform(lightProg.loc, "frustumScale")
    var znear = submitUniform(lightProg.loc, "zNear")
    var zfar = submitUniform(lightProg.loc, "zFar")

    setUniform1f(fscale, scale)
    setUniform1f(znear, zn)
    setUniform1f(zfar, zf)

proc brutelySwap*(window: GLFWWindow = wind) =
    window.swapBuffers()

proc brutelyDrawScreen*() =
    glBindFramebuffer(GL_FRAMEBUFFER, 0)

    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    glUseProgram(shaderOut)

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, colFBT)
    glGenerateMipmap(GL_TEXTURE_2D)

    glActiveTexture(GL_TEXTURE1)
    glBindTexture(GL_TEXTURE_2D, ligFBT)
    glGenerateMipmap(GL_TEXTURE_2D)

    glBindVertexArray(outVAO)

    glDisable(GL_DEPTH_TEST)

    glDrawElements(GL_TRIANGLES, (6).GlSizei, GL_UNSIGNED_INT, nil)


proc brutelyDrawCol1*(drawGroup: seq[Drawable] = drawSeq): float =
    var stt = cpuTime()

    #work

    glBindFramebuffer(GL_FRAMEBUFFER, colFBO)

    glEnable(GL_DEPTH_TEST)

    glUseProgram(defprog)

    #clear screen and apply program
    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    glActiveTexture(GL_TEXTURE0)

    #iterate through drawables and draw them
    for model in drawGroup:
        for dupe in model.dupes:
            var wtcopy = camMatr * dupe.worldTran
            var tintcopy = dupe.tint
            glBindTexture(GL_TEXTURE_2D, texSeq[dupe.tex])
            goonChooseItem(model)
            glUniformMatrix4fv(dprogwt, 1, GL_FALSE.GlBoolean, addr wtcopy[0][0])
            glUniform4fv(dprogco, 1, addr tintcopy[0])
            glDrawElements(GL_TRIANGLES, (model.vertCount).GlSizei, GL_UNSIGNED_INT, nil)
            #goonCloseBuffers()
    
    #flush, then ready for next state
    glFlush()
    
    goonCloseBuffers()

    #glUseProgram(0)

    var ent = cpuTime()
    return ent - stt

proc brutelyDrawLights*(drawGroup: seq[Drawable] = drawSeq, lights: seq[Light] = lightSeq): float =
    var stt = cpuTime()

    glBindFramebuffer(GL_FRAMEBUFFER, ligFBO)

    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    glBindFramebuffer(GL_FRAMEBUFFER, ligmixFBO)

    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    for ligt in lights:
        glBindFramebuffer(GL_FRAMEBUFFER, ligmixFBO2)
        glEnable(GL_DEPTH_TEST)

        glUseProgram(lightProg.loc)

        glClear(GL_COLOR_BUFFER_BIT)
        glClear(GL_DEPTH_BUFFER_BIT)
        for model in drawGroup:
            for dupe in model.dupes:
                var wtcopy = camMatr * dupe.worldTran
                var ligtcolcopy = ligt.col
                var ligtposcopy = ligt.pos
                goonChooseItem(model)
                glUniform3fv(lightProgWorld, 1, addr ligtposcopy[0])
                glUniformMatrix4fv(lightProg.wtloc, 1, GL_FALSE.GlBoolean, addr wtcopy[0][0])
                glUniform4fv(lightProg.colloc, 1, addr ligtcolcopy[0])
                glDrawElements(GL_TRIANGLES, (model.vertCount).GlSizei, GL_UNSIGNED_INT, nil)
        glBindFramebuffer(GL_FRAMEBUFFER, ligFBO)

        glUseProgram(shaderLightmix)

        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, ligmixFBT)
        glGenerateMipmap(GL_TEXTURE_2D)

        glActiveTexture(GL_TEXTURE1)
        glBindTexture(GL_TEXTURE_2D, ligmixFBT3)
        glGenerateMipmap(GL_TEXTURE_2D)

        glBindVertexArray(outVAO)

        glDisable(GL_DEPTH_TEST)

        glDrawElements(GL_TRIANGLES, (6).GlSizei, GL_UNSIGNED_INT, nil)

        glBindFramebuffer(GL_READ_FRAMEBUFFER, ligFBO)
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, ligmixFBO)
        glBlitFramebuffer(0.GlInt, 0.GlInt, WNDSIZE[0].GlInt, WNDSIZE[1].GlInt,
                            0.GlInt, 0.GlInt, WNDSIZE[0].GlInt, WNDSIZE[1].GlInt,
                            GL_COLOR_BUFFER_BIT.GlBitField, GL_LINEAR)

    glFlush()

    goonCloseBuffers()
    glUseProgram(0)

    var ent = cpuTime()
    return ent - stt

proc brutelyAddLight*(worldLocation: Vec3f, colour: Vec4f = vec4f(1.0,1.0,1.0,0.5)): uint =
    var newLight: Light
    newLight.pos = worldLocation
    newLight.col = colour
    lightSeq.add(newLight)
    return (lightSeq.len - 1).uint

proc brutelyModelSubmit*(model: BrutelyModel, modelName: string, culld, adraw: bool = false): uint =
    var tmpDrawable: Drawable = goonBuffersCreate()

    var tmpVerts = seqToUncheckedArrayGLFLOAT(model.verts)
    var tmpInds = seqToUncheckedArrayGLUINT(model.indices)
    var tmpUvs = seqToUncheckedArrayGLFLOAT(model.uvs)
    var tmpNorms = seqToUncheckedArrayGLFLOAT(model.normals)

    glBindBuffer(GL_ARRAY_BUFFER, tmpDrawable.VBO)
    glBufferData(GL_ARRAY_BUFFER, (model.verts.len * sizeof(GlFloat)), tmpVerts, GL_STATIC_DRAW)
    glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE.GlBoolean, (3 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(0)
    
    glBindBuffer(GL_ARRAY_BUFFER, tmpDrawable.TBO)
    glBufferData(GL_ARRAY_BUFFER, (model.uvs.len * sizeof(GlFloat)), tmpUvs, GL_STATIC_DRAW)
    glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE.GlBoolean, (2 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(1)

    glBindBuffer(GL_ARRAY_BUFFER, tmpDrawable.NBO)
    glBufferData(GL_ARRAY_BUFFER, (model.normals.len * sizeof(GlFloat)), tmpNorms, GL_STATIC_DRAW)
    glVertexAttribPointer(2, 3, cGL_FLOAT, GL_FALSE.GlBoolean, (3 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(2)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, tmpDrawable.EBO)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, (model.indices.len * sizeof(GlInt)), tmpInds, GL_STATIC_DRAW)
    goonCloseBuffers()
    glFlush()

    var tmpDupe: Duplicate

    tmpDrawable.vertCount = model.indices.len
    tmpDupe.worldTran = mat4f(1)
    tmpDupe.dupeName = "ORIGINAL"
    tmpDupe.tint = vec4f(1.0, 1.0, 1.0, 1.0)
    tmpDupe.tex = 0
    tmpDrawable.drawableName = modelName
    tmpDrawable.dupes.add(tmpDupe)

    drawSeq.add(tmpDrawable)

    return (drawSeq.len - 1).uint

proc brutelyModelDupe*(index: uint, worldTransform: Mat4x4[GlFloat], name: string, culld, adraw: bool = false): uint =
    var tmpDupe: Duplicate
    tmpDupe.worldTran = worldTransform
    tmpDupe.dupeName = name
    tmpDupe.tint = vec4f(1.0, 1.0, 1.0, 1.0)
    tmpDupe.tex = drawSeq[index].dupes[0].tex
    drawSeq[index].dupes.add(tmpDupe)
    
    return (drawSeq[index].dupes.len - 1).uint

proc brutelyDupeTexture*(modelIndex, dupeIndex, texIndex: uint) =
    drawSeq[modelIndex].dupes[dupeIndex].tex = texIndex

proc brutelyTintDupe*(modelIndex, dupeIndex: uint, colour: Vec4[GlFloat]) =
    drawSeq[modelIndex].dupes[dupeIndex].tint = colour

proc brutelyMoveDupe*(modelIndex, dupeIndex: uint, movement: Vec3f, absolute: bool = true) =
    if absolute:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran[3] = vec4(movement, 1.0)
    else:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran.translateInpl(movement)

proc brutelyLocateDupe*(modelIndex, dupeIndex: uint): Mat4 =
    return drawSeq[modelIndex].dupes[dupeIndex].worldTran

proc brutelyLookAtDupe*(modelIndex, dupeIndex: uint, pos, up: Vec3f, localspc: bool = false) =
    var strt = drawSeq[modelIndex].dupes[dupeIndex].worldTran
    if localspc:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran = lookAt(strt[3].xyz, strt[3].xyz + pos, up)
    else:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran = lookAt(strt[3].xyz, pos, up)

proc brutelyRotateDupe*(modelIndex, dupeIndex: uint, axis: Vec3f, deg: float) =
#    with drawSeq[modelIndex].dupes[dupeIndex]:
    drawSeq[modelIndex].dupes[dupeIndex].worldTran.rotateInpl(radToDeg(deg), axis)
    