import glm,glad/gl,prgconf

type
  ShaderProg* = object
    loc*: GlUint
    wtloc*, tintloc*: GlInt
  Duplicate* = object
    dupeName*: string
    culled*, alwaysdraw*: bool
    worldTran*: Mat4x4[GlFloat]
    tint*: Vec4[GlFloat]
    program*: uint
  Drawable* = object
    drawableName*: string
    VBO*, VAO*, EBO*, NBO*: GlUint
    vertCount*: int
    dupes*: seq[Duplicate]

proc gladLoad*(lp: proc) =
  when GLVER == "21":
    discard gladLoadGL(lp)
  when GLVER == "2ES" or GLVER == "3ES":
    discard gladLoadGLES2(lp)

proc goonChooseItem*(mdl: Drawable) =
  when GLVER == "21" or GLVER == "2ES":
    glBindBuffer(GL_ARRAY_BUFFER, mdl.VBO)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mdl.EBO)
    glEnableVertexAttribArray(0)
  when GLVER == "3ES":
    glBindVertexArray(mdl.VAO)

proc goonBuffersCreate*: Drawable =
  var tmpdrw: Drawable
  when GLVER == "3ES": glGenVertexArrays(1, addr tmpdrw.VAO)
  else: tmpdrw.VAO = 0

  glGenBuffers(1, addr tmpdrw.VBO)
  glGenBuffers(1, addr tmpdrw.EBO)
  glGenBuffers(1, addr tmpdrw.NBO)

  when GLVER == "3ES": glBindVertexArray(tmpdrw.VAO)
  return tmpdrw

proc goonCloseBuffers*() =
  when GLVER == "21" or GLVER == "2ES":
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)
    glDisableClientState(GL_VERTEX_ARRAY)
  else: glBindVertexArray(0)
