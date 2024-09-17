# tfx
Tfx is a toy single header graphics abstraction for OpenGL 3.3 and OpenGLes 3.0 in a very experimental stage.
It embeds glad for OpenGL function loading and stb_image.h for image loading and tries, to enable painless graphics prototyping.
It aims, to make OpenGL a bit less painless: When to unbind which buffer? What is the active depth compare function? etc...
The style leans a bit towards modern graphics apis, but tfx doesn't hide opengl away. You could just use it, to load it and then write plain gl code.
Right now it compiles as c on windows and linux. Other platforms are not tested.

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
        tfxSetPipeline(&(tfxPipeline){}); //actually not nescessary here.
        tfxSetShader(&shader);

        // Set the mesh (triangle) and draw it
        tfxSetMesh(&triangleMesh);
        tfxDraw(TFX_PRIMITIVTYPE_TRIANGLES, 3);

        // End the pass
        tfxEndPass(); //actually not nescessary here, unbinds the pass rendertarget

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // Cleanup
    tfxReleaseBuffer(&vertexBuffer);
    tfxReleaseShader(&shader);
    tfxReleaseMesh(&triangleMesh);
    glfwDestroyWindow(window);  // Destroy the window
    glfwTerminate();  // Terminate GLFW
    return 0;
}


```

