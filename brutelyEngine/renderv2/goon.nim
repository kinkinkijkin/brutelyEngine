import glm,glad/gl,prgconf

type
  ShaderProg* = object
    loc*: GlUint
    wtloc*, colloc*: GlInt
  Duplicate* = object
    dupeName*: string
    worldTran*: Mat4x4[GlFloat]
    tint*: Vec4[GlFloat]
    tex*: uint
  Drawable* = object
    drawableName*: string
    VBO*, VAO*, EBO*, NBO*, TBO*: GlUint
    vertCount*: int
    dupes*: seq[Duplicate]
  Light* = object
    pos*: Vec3f
    col*: Vec4f

when GLVER == "3ES":
    let defVShad* = "shaders/ES3/vdefault.glsl"
    let defFShad* = "shaders/ES3/fdefault.glsl"
else:
    let defVShad* = "shaders/v1.glsl"
    let defFShad* = "shaders/f1.glsl"

proc gladLoad*(lp: proc) =
  when GLVER == "21":
    discard gladLoadGL(lp)
  when GLVER == "2ES" or GLVER == "3ES":
    discard gladLoadGLES2(lp)

proc goonChooseItem*(mdl: Drawable) =
  when GLVER == "21" or GLVER == "2ES":
    glBindBuffer(GL_ARRAY_BUFFER, mdl.VBO)
    glBindBuffer(GL_ARRAY_BUFFER, mdl.TBO)
    glBindBuffer(GL_ARRAY_BUFFER, mdl.NBO)
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
  glGenBuffers(1, addr tmpdrw.TBO)

  when GLVER == "3ES": glBindVertexArray(tmpdrw.VAO)
  return tmpdrw

proc goonCloseBuffers*() =
  when GLVER == "21" or GLVER == "2ES":
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)
    glDisableClientState(GL_VERTEX_ARRAY)
  else: glBindVertexArray(0)
