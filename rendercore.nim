import glm,glad/gl,nimgl/glfw,initcore,times,datahelpers

var prog*: GlUint

type
    Duplicate = object
        culled, alwaysdraw: bool
        dupeName: string
        worldTran: Mat4x4[GlFloat]
        tint: Vec4[GlFloat]
    Drawable = object
        VBO, VAO, EBO, NBO: GlUint
        drawableName: string
        vertCount: int
        dupes: seq[Duplicate]
    
var drawSeq: seq[Drawable] = @[]
var unifSeq: seq[Glint] = @[]
var wtloc: GlInt = 0.GlInt
var tintloc: GlInt = 0.GlInt

proc submitUniform*(program: GlUint, name: string): uint =
    var unif = glGetUniformLocation(program, name)
    unifSeq.add(unif)
    return (unifSeq.len - 1).uint

proc setUniform1f*(location: uint, value: float) =
    glUniform1f(unifSeq[location], value.GlFloat)

proc setUniform3fv*(location: uint, value: Vec3[GlFloat]) =
    glUniform3f(unifSeq[location], value.x, value.y, value.z)

proc setUniformM4fv*(location: uint, value: Mat4[GlFloat]) =
    var valueCopy = value
    glUniformMatrix4fv(unifSeq[location], 1, GL_FALSE.GlBoolean, addr valueCopy[0][0])

proc submitWTLoc*(location: GlInt) =
    wtloc = location

proc submitTintLoc(location: GlInt) =
    tintloc = location

proc brutelySetup*() =
    assert brutelyStart()
    prog = prepareES3program(@["shaders/v1.glsl"], @["shaders/f1.glsl"])
    submitTintLoc(glGetUniformLocation(prog, "modelTint"))

proc brutelyDraw*(): float =
    var stt = cpuTime()

    #work

    #clear screen and apply program
    glClear(GL_COLOR_BUFFER_BIT)
    glClear(GL_DEPTH_BUFFER_BIT)

    glUseProgram(prog)

    #iterate through drawables and draw them
    for model in drawSeq:
        for dupe in model.dupes:
            if dupe.alwaysdraw or not dupe.culled:
                var wtcopy = dupe.worldTran
                var tintcopy = dupe.tint
                glBindVertexArray(model.VAO)
                glUniformMatrix4fv(wtloc, 1, GL_FALSE.GlBoolean, addr wtcopy[0][0])
                glUniform4fv(tintloc, 1, addr tintcopy[0])
                glDrawElements(GL_TRIANGLES, model.vertCount.GlSizei, GL_UNSIGNED_INT, nil)
    
    #flush, then ready for next state
    #glFlush()
    glBindVertexArray(0)

    glUseProgram(0)

    wind.swapBuffers()

    var ent = cpuTime()
    return ent - stt

proc brutelyModelSubmit*(model: BrutelyModel, modelName: string, culld, adraw: bool = false): uint {.gcsafe.} =
    var tmpDrawable: Drawable

    glGenBuffers(1, addr tmpDrawable.VBO)
    glGenVertexArrays(1, addr tmpDrawable.VAO)
    glGenBuffers(1, addr tmpDrawable.EBO)
    glGenBuffers(1, addr tmpDrawable.NBO)

    var tmpVerts = seqToUncheckedArrayGLFLOAT(model.verts)
    var tmpInds = seqToUncheckedArrayGLUINT(model.indices)
    var tmpNorms = seqToUncheckedArrayGLFLOAT(model.normals)

    glBindVertexArray(tmpDrawable.VAO)
    glBindBuffer(GL_ARRAY_BUFFER, tmpDrawable.VBO)
    glBufferData(GL_ARRAY_BUFFER, (model.verts.len * sizeof(GlFloat)), tmpVerts, GL_STATIC_DRAW)
    glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE.GlBoolean, (3 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(0)

    glBindBuffer(GL_ARRAY_BUFFER, tmpDrawable.NBO)
    glBufferData(GL_ARRAY_BUFFER, (model.normals.len * sizeof(GlFloat)), tmpNorms, GL_STATIC_DRAW)    
    glVertexAttribPointer(1, 3, cGL_FLOAT, GL_FALSE.GlBoolean, (3 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(1)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, tmpDrawable.EBO)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, (model.indices.len * sizeof(GlInt)), tmpInds, GL_STATIC_DRAW)

    glFlush()

    var tmpDupe: Duplicate

    tmpDrawable.vertCount = model.verts.len
    tmpDupe.culled = culld
    tmpDupe.alwaysdraw = adraw
    tmpDupe.worldTran = mat4f(1)
    tmpDupe.dupeName = "ORIGINAL"
    tmpDupe.tint = vec4f(1.0, 1.0, 1.0, 1.0)
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
    drawSeq[index].dupes.add(tmpDupe)
    
    return (drawSeq[index].dupes.len - 1).uint

proc brutelyTintDupe*(modelIndex, dupeIndex: uint, colour: Vec4[GlFloat]) =
    drawSeq[modelIndex].dupes[dupeIndex].tint = colour

proc brutelyMoveDupe*(modelIndex, dupeIndex: uint, movement: Vec3f, absolute: bool = true) =
    if absolute:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran[3] = vec4(movement, 1.0)
    else:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran.translateInpl(movement)