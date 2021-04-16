import glad/gl,sequtils,strutils,datahelpers

proc getOBJ*(fileName:string, indexDelimiter:string = "/"):BrutelyModel {.gcsafe.} =
    var tmpVertList:seq[seq[GlFloat]] = @[]
    var tmpUvList:seq[seq[GlFloat]] = @[]
    var tmpNorm:seq[GlFloat] = @[]
    var tmpNormList:seq[seq[GlFloat]] = @[]
    var currLineSplit:seq[string] = @[]
    var currIndexSplit:seq[string] = @[]
    var tmpFaceList:seq[seq[GlUint]] = @[]
    var tmpUvIndices:seq[GlUint] = @[]
    var tmpNormIndices:seq[GlUint] = @[]
    for line in lines(fileName):
        currLineSplit = @[]
        if line.startsWith("v "):
            var tmpVert:seq[GlFloat] = @[]
            currLineSplit = line.splitWhitespace()
            tmpVert.add(currLineSplit[1].parseFloat.GlFloat)
            tmpVert.add(currLineSplit[2].parseFloat.GlFloat)
            tmpVert.add(currLineSplit[3].parseFloat.GlFloat)
            tmpVertList.add(tmpVert.toSeq())
        elif line.startsWith("vt "):
            var tmpUv:seq[GlFloat] = @[]
            currLineSplit = line.splitWhitespace()
            tmpUv.add(currLineSplit[1].parseFloat.GlFloat)
            tmpUv.add(currLineSplit[2].parseFloat.GlFloat)
            tmpUvList.add(tmpUv.toSeq())
        elif line.startsWith("vn "):
            var tmpNorm:seq[GlFloat] = @[]
            currLineSplit = line.splitWhitespace()
            tmpNorm.add(currLineSplit[1].parseFloat.GlFloat)
            tmpNorm.add(currLineSplit[2].parseFloat.GlFloat)
            tmpNorm.add(currLineSplit[3].parseFloat.GlFloat)
            tmpNormList.add(tmpNorm.toSeq())
        elif line.startsWith("f "):
            currLineSplit = line.splitWhitespace()
            var tmpFace:seq[GlUint] = @[]
            for indice in currLineSplit:
                block ind:
                    if indice.startsWith("f"):
                        break ind
                    if indice.contains(indexDelimiter):
                        
                        currIndexSplit = indice.split(indexDelimiter)
                        tmpFace.add(currIndexSplit[0].parseUint().GlUint - 1)
                        try:
                            tmpUvIndices.add(currIndexSplit[1].parseUint().GlUint - 1)
                            tmpNormIndices.add(currIndexSplit[2].parseUint().GlUint - 1)
                        except ValueError: break ind
                        break ind
                    else: tmpFace.add(indice.parseUint().GlUint - 1)
            tmpFaceList.add(tmpFace)
            
    result.indices = tmpFaceList.concat()
    
    var tmpUL, tmpNL: seq[seq[GlFloat]] = @[]
    
    tmpUL.setLen(tmpVertList.len)
    tmpNL.setLen(tmpVertList.len)
    
    if not (tmpUvIndices.len < result.indices.len):
        for ind, i in result.indices:
            tmpUL[ind] = tmpUvList[tmpUvIndices[i]]
    else:
        tmpUL = tmpUvList
        echo "a very empty obj"
        
    if not (tmpNormIndices.len < result.indices.len):
        for ind, i in result.indices:
            tmpNL[ind] = tmpNormList[tmpNormIndices[i]]
    else:
        tmpNL = tmpNormList
        echo "a very empty obj"
        
    result.verts = tmpVertList.concat()
    result.uvs = tmpUL.concat()
    result.normals = tmpNL.concat()
    return result
