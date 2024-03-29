import goon,glm,glad/gl,nimgl/glfw,initcore,times,datahelpers,nimPNG,math

var defprog*: GlUint

var progSeq: seq[ShaderProg] = @[]
var drawSeq: seq[Drawable] = @[]
var unifSeq: seq[Glint] = @[]
var texSeq: seq[Gluint] = @[0.Gluint]

var camMatr*: Mat4f = mat4f(1.0)

proc submitUniform*(program: GlUint, name: string): uint =
    var unif = glGetUniformLocation(program, name)
    unifSeq.add(unif)
    return (unifSeq.len - 1).uint

proc submitProgram*(program: GlUint, wt, tint: GlInt): uint =
    var tmpSP: ShaderProg
    tmpSP.loc = program
    tmpSP.wtloc = wt
    tmpSP.tintloc = tint
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
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR.Glint)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR.Glint)
    
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

proc brutelySetup*() =
    assert brutelyStart()
    defprog = prepareES3program(@[defVShad], @[defFShad])
    var tloc = glGetUniformLocation(defprog, "modelTint")
    var wtloc = glGetUniformLocation(defprog, "worldTransform")
    discard submitProgram(defprog, wtloc, tloc)

proc brutelyDraw*(drawGroup: seq[Drawable] = drawSeq): float =
    var stt = cpuTime()

    #work

    #clear screen and apply program
    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    #glUseProgram(defprog)

    #iterate through drawables and draw them
    for model in drawGroup:
        for dupe in model.dupes:
            if dupe.alwaysdraw or not dupe.culled:
                var wtcopy = camMatr * dupe.worldTran
                var tintcopy = dupe.tint
                var currpro = progSeq[dupe.program]
                glUseProgram(currpro.loc)
                glBindTexture(GL_TEXTURE_2D, texSeq[dupe.tex])
                goonChooseItem(model)
                glUniformMatrix4fv(currpro.wtloc, 1, GL_FALSE.GlBoolean, addr wtcopy[0][0])
                glUniform4fv(currpro.tintloc, 1, addr tintcopy[0])
                glDrawElements(GL_TRIANGLES, (model.vertCount).GlSizei, GL_UNSIGNED_INT, nil)
                #goonCloseBuffers()
    
    #flush, then ready for next state
    glFlush()
    
    goonCloseBuffers()

    glUseProgram(0)

    wind.swapBuffers()

    var ent = cpuTime()
    return ent - stt

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
    tmpDupe.culled = culld
    tmpDupe.alwaysdraw = adraw
    tmpDupe.worldTran = mat4f(1)
    tmpDupe.dupeName = "ORIGINAL"
    tmpDupe.tint = vec4f(1.0, 1.0, 1.0, 1.0)
    tmpDupe.program = 0
    tmpDupe.tex = 0
    tmpDrawable.drawableName = modelName
    tmpDrawable.dupes.add(tmpDupe)

    drawSeq.add(tmpDrawable)

    return (drawSeq.len - 1).uint

proc brutelyModelDupe*(index: uint, worldTransform: Mat4x4[GlFloat], name: string, culld, adraw: bool = false): uint =
    var tmpDupe: Duplicate
    tmpDupe.culled = culld
    tmpDupe.alwaysdraw = adraw
    tmpDupe.worldTran = worldTransform
    tmpDupe.dupeName = name
    tmpDupe.tint = vec4f(1.0, 1.0, 1.0, 1.0)
    tmpDupe.program = drawSeq[index].dupes[0].program
    tmpDupe.tex = drawSeq[index].dupes[0].tex
    drawSeq[index].dupes.add(tmpDupe)
    
    return (drawSeq[index].dupes.len - 1).uint

proc brutelyDupeTexture*(modelIndex, dupeIndex, texIndex: uint) =
    drawSeq[modelIndex].dupes[dupeIndex].tex = texIndex

proc brutelyProgDupe*(modelIndex, dupeIndex, progIndex: uint) =
    drawSeq[modelIndex].dupes[dupeIndex].program = progIndex

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
    