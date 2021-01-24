import glad/gl,sequtils,strutils,datahelpers

proc getPLY(filename:string):BrutelyModel =
    var tmpVert: seq[GlFloat] = @[]
    var tmpFace: seq[GlUint] = @[]
    var vertCount: uint = 0
    var faceCount: uint = 0
    var vertSize: uint = 3
    var vertOrder: seq[string] = @[]
    var tmpVertList: seq[seq[GLfloat]] = @[]
    var tmpFaceList: seq[seq[GLuint]] = @[]

    var extraElements: seq[tuple[name:string, size:uint, order:seq[string]]] = @[]
    var extraElementValues: seq[seq[string]] = @[]

    var currElement:string = "vertex"

    var isActuallyPLY: bool = false
    var readable: bool = false
    var headerSec: bool = true

    for line in lines(filename):
        if headerSec:
            if line.startsWith("ply"):
                isActuallyPly = true
            elif line.startsWith("format ascii 1.0"):
                readable = true
            elif line.startsWith("end_header"):
                headerSec = false
            elif line.startsWith("property"):
                if currElement.startsWith("vertex"):
                    vertOrder.add(line.splitWhitespace()[2])
                elif currElement.startsWith("face"):
                    block b:
                        break b
                else:
                    for i in 0..(extraElements.len-1):
                        if extraElements[i].name == currElement:
                            extraElements[i].order.add(line)
                            break
            elif line.startsWith("element"):
                var lineSplit = line.splitWhitespace()
                currElement = lineSplit[1]
                if currElement.startsWith("vertex"):
                    vertCount = lineSplit[2].parseUInt()
                elif currElement.startsWith("face"):
                    faceCount = lineSplit[2].parseUInt()
                else:
                    extraElements.add((currElement, lineSplit[2].parseUInt, @[]))
                    extraElementValues.add(@[])
            