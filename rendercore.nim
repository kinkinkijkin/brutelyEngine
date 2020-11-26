import glm,glad/gl,nimgl/glfw,initcore,times,datahelpers

var prog*: GlUint

type
    Duplicate = object
        culled, alwaysdraw: bool
        dupeName: string
        worldTran: Mat4x4[GlFloat]
    Drawable = object
        VBO, VAO, EBO: GlUint
        drawableName: string
        vertCount: int
        dupes: seq[Duplicate]
    
var drawSeq: seq[Drawable] = @[]
var unifSeq: seq[Glint] = @[]
var wtloc: GlInt = 0.GlInt

proc submitUniform*(program: GlUint, name: string): uint =
    var unif = glGetUniformLocation(program, name)
    unifSeq.add(unif)
    return (unifSeq.len - 1).uint

proc setUniform1f*(location: uint, value: float) =
    glUniform1f(unifSeq[location], value.GlFloat)

proc setUniformM4fv*(location: uint, value: Mat4[GlFloat]) =
    var valueCopy = value
    glUniformMatrix4fv(unifSeq[location], 1, GL_FALSE.GlBoolean, addr valueCopy[0][0])

proc submitWTLoc*(location: GlInt) =
    wtloc = location

proc brutelySetup*() =
    assert brutelyStart()
    prog = prepareES3program(@["shaders/v1.glsl"], @["shaders/f1.glsl"])

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
                glBindVertexArray(model.VAO)
                glUniformMatrix4fv(wtloc, 1, GL_FALSE.GlBoolean, addr wtcopy[0][0])
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

    var tmpVerts = seqToUncheckedArrayGLFLOAT(model.verts)
    var tmpInds = seqToUncheckedArrayGLUINT(model.indices)

    glBindVertexArray(tmpDrawable.VAO)
    glBindBuffer(GL_ARRAY_BUFFER, tmpDrawable.VBO)
    glBufferData(GL_ARRAY_BUFFER, (model.verts.len * sizeof(GlFloat)), tmpVerts, GL_STATIC_DRAW)

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, tmpDrawable.EBO)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, (model.indices.len * sizeof(GlInt)), tmpInds, GL_STATIC_DRAW)

    glVertexAttribPointer(0, 3 , cGL_FLOAT, GL_FALSE.GlBoolean, (3 * sizeof(GlFloat)).GlSizei, nil)
    glEnableVertexAttribArray(0)

    glFlush()

    var tmpDupe: Duplicate

    tmpDrawable.vertCount = model.verts.len
    tmpDupe.culled = culld
    tmpDupe.alwaysdraw = adraw
    tmpDupe.worldTran = mat4f(1)
    tmpDupe.dupeName = "ORIGINAL"
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
    drawSeq[index].dupes.add(tmpDupe)
    
    return (drawSeq[index].dupes.len - 1).uint

proc brutelyMoveDupe*(modelIndex, dupeIndex: uint, movement: Vec3f, absolute: bool = true) =
    if absolute:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran[3] = vec4(movement, 1.0)
    else:
        drawSeq[modelIndex].dupes[dupeIndex].worldTran.translateInpl(movement)