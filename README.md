# tfx
Tfx is an easy to use toy single header WIP graphics abstraction for OpenGL 3.3 and OpenGLes 3.0.
It embeds glad for OpenGL function loading and stb_image.h for image loading and tries, to enable painless graphics prototyping.

It aims, to make OpenGL a bit less of a struggle: When to unbind the index buffer? What is the active depth compare function? And why is everything an int?!
The style leans a bit towards modern graphics apis, but tfx doesn't hide opengl away. You could just use it, to load it and then write plain gl code.

If you are looking for something more mature, have a look at sokol_gfx.h or bgfx.
Right now it compiles as C and c++ on windows and linux. Other platforms should work, but are not tested.

To use it, just drop the header file into your project, include it and define TFX_IMPL and the backend (TFX_GLCORE/TFX_GLES2) in *one* C/C++ file.

The different licenses are included in the header file, which are MIT/PublicDomain for stb_image.h, WTFPL OR CC0-1.0 AND Apache-2.0 for the glad-headers and the uLicense for the actual code of tfx.

Credits:
David Herberth - [glad](https://github.com/Dav1dde/glad) /
Sean Barrett - [stb_image](https://github.com/nothings/stb) /
r-lyeh - [uLicense](https://github.com/r-lyeh/uLicense)

## triangle example using glfw for windowing
```c
#define TFX_IMPL
#define TFX_GLCORE //can also be TFX_GLES2
#include "tfx.h"
#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>


int main() {
    if (!glfwInit()) {
        fprintf(stderr, "Failed to initialize GLFW\n");
        exit(EXIT_FAILURE);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_API);

    GLFWwindow* window = glfwCreateWindow(640, 480, "Triangle", NULL, NULL);
    if (!window) {
        fprintf(stderr, "Failed to create GLFW window\n");
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);

    // Initialize tfx
    if (!tfxInit(glfwGetProcAddress)) {
        fprintf(stderr, "Failed to initialize tfx\n");
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    // Define the vertices of the triangle (X, Y, Z)
    static const float triangleVertices[] = {
        0.0f,  0.5f, 0.0f,
       -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f
    };

    // Create a buffer for triangle vertices
    tfxBuffer vertexBuffer = (tfxBuffer){
        .stride = 3 * sizeof(float),
        .usage = TFX_USAGE_IMMUTABLE,
        .data = TFX_MEMORY(triangleVertices),
        .type = TFX_BUFFERTYPE_VERTEXBUFFER
    };

    tfxShader shader = tfxLoadShader("triangle.vert", "triangle.frag");

    // Define the mesh with the vertex buffer and layout
    // here the actual opengl ressources are initialized
    tfxMeshDesc meshDesc = {
        .vbuf[0] = &vertexBuffer,
        .layout = {
            [0] = {
                .size = 3,
                .offset = 0,
                .bufferIndex = 0
            }
        }
    };
    tfxMesh triangleMesh = tfxMakeMesh(&meshDesc);

    // Render loop
    while (!glfwWindowShouldClose(window)) {
        // Clear the screen
        tfxBeginPass(&(tfxPass) {
            .clearFlags = TFX_CLEAR_COLOR | TFX_CLEAR_DEPTH,
            .clearValue = (tfxColor){0.1f, 0.1f, 0.1f, 1.0f},
            .framebuffer = {0}
        });

        // Set the pipeline and shader
        tfxSetPipeline(&(tfxPipeline){}); // Actually not nescessary here.
        tfxSetShader(&shader);

        // Set the mesh (triangle) and draw it
        tfxSetMesh(&triangleMesh);
        tfxDraw(TFX_PRIMITIVTYPE_TRIANGLES, 3);

        // End the pass
        tfxEndPass(); // Actually not nescessary here, binds the default/0th framebuffer.

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // Cleanup
    tfxReleaseBuffer(&vertexBuffer);
    tfxReleaseShader(&shader);
    tfxReleaseMesh(&triangleMesh);
    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}


```

