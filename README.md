# brutelyEngine
game engine based around simplicity and data cleanliness. Not production-ready

to use, you must have Nimgl (for glfw), glm (for maths), and generate a gles3 or gles2.1 loader for nim with GLAD. no minimum extensions, but no extensions are used right now.

for testing/learning purposes, I have included simple tests. to compile them, simply nim c desired-test.nim, then run.

the entire engine is built modularly and as a set of code parts, you have to write the code that puts these parts together currently.
