import sequtils,glad/gl,strutils,nimgl/glfw,nimPNG

type
  ProgInfo* = object
    name*, windowname*: string
    windowsize*: tuple[x, y: int]
    version*: tuple[maj, min, hf, bui: int]
  BrutelyModel* = object
    verts*, uvs*, normals*: seq[GlFloat]
    indices*: seq[GlUint]
  BrutelyTex* = object
    texture*: Pixels
  
var wind*: GLFWWindow

#verts seq is **3** coords per vert, no perspective coord or padding
#UVs is 2 numbers per UV
#normals is 3 normalized floats
#indices is 3 integers, pointing to the start of each needed vert

proc seqToUncheckedArrayGLFLOAT*(inseq:seq[GlFloat]):ptr UncheckedArray[GlFloat] =
  var outUCA = cast[ptr UncheckedArray[GlFloat]](alloc0(sizeof(GlFloat) * inseq.len))
  for i in 0..(inseq.len - 1):
    outUCA[i] = inseq[i]
  return outUCA

proc seqToUncheckedArrayGLUINT*(inseq:seq[GlUint]):ptr UncheckedArray[GlUint] =
  var outUCA = cast[ptr UncheckedArray[GlUint]](alloc0(sizeof(GlUint) * inseq.len))
  for i in 0..(inseq.len - 1):
    outUCA[i] = inseq[i]
  return outUCA

proc seqToUncheckedArrayUINT8*(inseq:seq[uint8]):ptr UncheckedArray[uint8] =
  var outUCA = cast[ptr UncheckedArray[uint8]](alloc0(sizeof(uint8) * inseq.len))
  for i in 0..(inseq.len - 1):
    outUCA[i] = inseq[i]
  return outUCA

proc sourceToCSARRAY*(source: seq[string]): cstringArray =
  var tmpstring: string
  for line in source:
    tmpstring = join([tmpstring, line, "\n"])
  result = allocCstringArray(@[tmpstring])
  return result
