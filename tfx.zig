const builtin = @import("builtin");

pub const BufferType = enum(i32) {
    VERTEXBUFFER = 0x8892,
    INDEXBUFFER = 0x8893,
};

pub const IndexFormat = enum(i32) {
    NONE = 0,
    U16 = 0x1403,
    U32 = 0x1405,
};

pub const VertexFormat = enum(i32) {
    F32 = 0x1406,
};

pub const PixelFormat = enum(i32) {
    NONE = 0,
    U8 = 0x1401,
    F32 = 0x1406,
};

pub const TextureFormat = enum(i32) {
    NONE = 0,
    R = 0x1903,
    RGB = 0x1907,
    RGBA = 0x1908,
};

pub const PrimitiveType = enum(i32) {
    POINTS = 0,
    LINES = 1,
    LINE_STRIP = 3,
    TRIANGLES = 4,
    TRIANGLE_STRIP = 5,
    TRIANGLE_FAN = 6,
};

pub const Filter = enum(i32) {
    NEAREST = 0x2600,
    LINEAR = 9729,
    NEAREST_MIPMAP_NEAREST = 0x2700,
    NEAREST_MIPMAP_LINEAR = 0x2701,
    LINEAR_MIPMAP_LINEAR = 0x2703,
};

pub const Wrap = enum(i32) {
    CLAMP_TO_EDGE = 0x812F,
    REPEAT = 0x2901,
    MIRRORED_REPEAT = 0x8370,
};

pub const TextureType = enum(i32) {
    _2D = 0x0DE1,
    CUBE = 0x8531,
    _3D = 0x806F,
    ARRAY_2D = 0x8C1A,
};

pub const Usage = enum(i32) {
    IMMUTABLE = 0x88E4,
    DYNAMIC = 0x88E8,
    STREAM = 0x88E0,
};

pub const Face = enum(i32) {
    NONE = 0,
    FRONT = 0x0404,
    BACK = 0x0405,
    FRONT_BACK = 0x0408,
};

pub const Winding = enum(i32) {
    CW = 0x0900,
    CCW = 0x901,
};

pub const CompareFunc = enum(i32) {
    NEVER = 0x200,
    LESS = 0x201,
    EQUAL = 0x202,
    LESS_EQUAL = 0x203,
    GREATER = 0x204,
    NOT_EQUAL = 0x205,
    GREATER_EQUAL = 0x206,
    ALWAYS = 0x207,
};

pub const StencilOp = enum(i32) {
    KEEP = 0x1E00,
    ZERO = 0,
    REPLACE = 0x1E01,
    INCR = 0x1E02,
    DECR = 0x1E03,
    INVERT = 0x150A,
    INCR_WRAP = 0x8507,
    DECR_WRAP = 0x8508,
};

pub const BlendMode = enum(i32) {
    NONE,
    ALPHA_TO_COVERAGE,
    BLEND,
    ADD,
};

pub const CLEAR_COLOR: u16 = 0x00004000;
pub const CLEAR_DEPTH: u16 = 256;

//pub const LoaderFn = *const fn ([*:0]const u8) ?*const anyopaque;

pub extern fn tfxInit(*const anyopaque) i32;
pub fn init(loader: *const anyopaque) i32 {
    return tfxInit(loader);
}

pub extern fn tfxViewport(i32, i32, i32, i32) void;
pub fn viewport(x: i32, y: i32, w: i32, h: i32) void {
    tfxViewport(x, y, w, h);
}

pub extern fn tfxDrawIndexed(PrimitiveType, i32, i32) void;
pub fn drawIndexed(mode: PrimitiveType, first: i32, numElements: i32) void {
    tfxDrawIndexed(mode, first, numElements);
}

pub extern fn tfxDraw(PrimitiveType, i32) void;
pub fn draw(mode: PrimitiveType, numElements: i32) void {
    tfxDraw(mode, numElements);
}

pub extern fn tfxDrawInstanced(PrimitiveType, i32, i32, i32) void;
pub fn drawInstanced(mode: PrimitiveType, first: i32, count: i32, numInstances: i32) void {
    tfxDrawInstanced(mode, first, count, numInstances);
}

pub const Memory = extern struct {
    ptr: ?*const anyopaque = null,
    size: usize = 0,
};

pub extern fn tfxReadFile([*c]const u8) Memory;
pub fn readFile(path: [*c]const u8) Memory {
    return tfxReadFile(path);
}

pub extern fn tfxReleaseMemory([*c]Memory) void;
pub fn releaseMemmory(mem: [*c]Memory) void {
    tfxReleaseMemory(mem);
}

fn cStrToZig(cstr: [*c]const u8) [:0]const u8 {
    return @import("std").mem.span(cstr);
}

pub fn asMemory(val: anytype) Memory {
    const type_info = @typeInfo(@TypeOf(val));
    // FIXME: naming convention change between 0.13 and 0.14-dev
    if (@hasField(@TypeOf(type_info), "Pointer")) {
        switch (type_info) {
            .Pointer => {
                switch (type_info.Pointer.size) {
                    .One => return .{ .ptr = val, .size = @sizeOf(type_info.Pointer.child) },
                    .Slice => return .{ .ptr = val.ptr, .size = @sizeOf(type_info.Pointer.child) * val.len },
                    else => @compileError("FIXME: Pointer type!"),
                }
            },
            .Struct, .Array => {
                @compileError("Structs and arrays must be passed as pointers to asMemory");
            },
            else => {
                @compileError("Cannot convert to tfx.Memory!");
            },
        }
    } else {
        switch (type_info) {
            .pointer => {
                switch (type_info.pointer.size) {
                    .One => return .{ .ptr = val, .size = @sizeOf(type_info.pointer.child) },
                    .Slice => return .{ .ptr = val.ptr, .size = @sizeOf(type_info.pointer.child) * val.len },
                    else => @compileError("FIXME: Pointer type!"),
                }
            },
            .@"struct", .array => {
                @compileError("Structs and arrays must be passed as pointers to asMemory");
            },
            else => {
                @compileError("Cannot convert to tfxMemory!");
            },
        }
    }
}

pub const Buffer = extern struct {
    id: u32 = 0,
    stride: i32 = 0,
    data: Memory = .{},
    usage: Usage = Usage.IMMUTABLE,
    type: BufferType = BufferType.VERTEXBUFFER,
};

pub extern fn tfxReleaseBuffer([*c]Buffer) void;
pub fn releaseBuffer(buffer: [*c]Buffer) void {
    tfxReleaseBuffer(buffer);
}

pub const VertexAttr = extern struct {
    size: i32 = 0,
    offset: u64 = 0,
    bufferIndex: i32 = 0,
    divisor: i32 = 0,
    format: VertexFormat = VertexFormat.F32,
};

pub const MAX_VERTEX_BUFFERS: u8 = 4;

pub const MeshDesc = extern struct {
    vbuf: [MAX_VERTEX_BUFFERS]*Buffer = undefined,
    layout: [MAX_VERTEX_BUFFERS]VertexAttr = [_]VertexAttr{.{}} ** MAX_VERTEX_BUFFERS,
    ibuf: *Buffer = undefined,
};

pub const Mesh = extern struct {
    handle: u32 = 0,
};

pub extern fn tfxMakeMesh([*c]MeshDesc) Mesh;
pub fn makeMesh(desc: [*c]MeshDesc) Mesh {
    return tfxMakeMesh(desc);
}

pub extern fn tfxReleaseMesh([*c]Mesh) void;
pub fn releaseMesh(mesh: [*c]Mesh) void {
    tfxReleaseMesh(mesh);
}

pub extern fn tfxSetMesh([*c]const Mesh) void;
pub fn setMesh(mesh: [*c]Mesh) void {
    tfxSetMesh(mesh);
}

//--TEXTURE-----------------------------------

pub const ImageData = extern struct {
    data: ?*anyopaque = null,
    width: i32 = 0,
    height: i32 = 0,
    format: TextureFormat = TextureFormat.NONE,
};

pub const TextureParams = extern struct {
    wrapS: Wrap = Wrap.CLAMP_TO_EDGE,
    wrapT: Wrap = Wrap.CLAMP_TO_EDGE,
    minFilter: Filter = Filter.LINEAR,
    magFilter: Filter = Filter.LINEAR,
};

pub extern fn tfxLoadImageData([*c]const u8) ImageData;
pub fn loadImageData(cstr: [*c]const u8, desiredChannels: i32) ImageData {
    return tfxLoadImageData(cstr, desiredChannels);
}

pub extern fn tfxLoadImageDataMem([*c]const Memory, i32) ImageData;
pub fn loadImageDataMem(mem: [*c]const Memory, desiredChannels: i32) ImageData {
    return tfxLoadImageDataMem(mem, desiredChannels);
}

pub extern fn tfxReleaseImageData([*c]ImageData) void;
pub fn releaseImageData(data: [*c]ImageData) void {
    tfxReleaseImageData(data);
}

pub const TextureDesc = extern struct {
    img: ImageData = ImageData{.{}},
    params: TextureParams = TextureParams{.{}},
};

pub const Texture = extern struct {
    handle: u32 = 0,
};

pub extern fn tfxMakeTexture([*c]const TextureDesc) Texture;
pub fn makeTexture(desc: [*c]const TextureDesc) Texture {
    return tfxMakeTexture(desc);
}

pub extern fn tfxLoadTexture([*c]const u8, [*c]const TextureParams) Texture;
pub fn loadTexure(path: [*c]const u8, params: [*c]const TextureParams) Texture {
    return tfxLoadTexture(path, params);
}

pub extern fn tfxLoadTextureMem([*c]const Memory, [*c]const TextureParams) Texture;
pub fn loadTextureMem(data: [*c]const Memory, params: [*c]const TextureParams) Texture {
    return tfxLoadTexture(data, params);
}

pub extern fn tfxSetTexture([*c]Texture, u32) void;
pub fn setTexture(tex: [*c]Texture, unit: u32) void {
    tfxSetTexture(tex, unit);
}

pub extern fn tfxUnbindTexture([*c]Texture, u32) void;
pub fn unbindTexture(tex: [*c]Texture, unit: u32) void {
    tfxUnbindTexture(tex, unit);
}

pub extern fn tfxReleaseTexture([*c]Texture) void;
pub fn releaseTexture(tex: [*c]Texture) void {
    tfxReleaseTexture(tex);
}

pub const RenderTargetDesc = extern struct {
    width: i32 = 0,
    height: i32 = 0,
    createDepthTex: bool = false,
    format: PixelFormat = PixelFormat{.{}},
    params: TextureParams = TextureParams{.{}},
};

pub const RenderTarget = extern struct {
    fbo: u32,
    colorTexture: Texture,
    depthTexture: Texture,
    rbo: u32,
};

pub extern fn tfxMakeRenderTarget([*c]const RenderTargetDesc) RenderTarget;
pub fn makeRenderTarget(desc: [*c]const RenderTargetDesc) RenderTarget {
    return tfxMakeRenderTarget(desc);
}

pub extern fn tfxSetRenderTarget([*c]const RenderTarget) void;
pub fn setRenderTarget(target: [*c]const RenderTarget) void {
    tfxSetRenderTarget(target);
}

pub extern fn tfxUnbindRenderTarget() void;
pub fn unbindRenderTarget() void {
    tfxUnbindRenderTarget();
}

pub extern fn tfxReleaseRenderTarget([*c]const RenderTarget) void;
pub fn releaseRenderTarget(target: [*c]const RenderTarget) void {
    tfxReleaseRenderTarget(target);
}

pub const Shader = extern struct {
    handle: u32,
};

pub extern fn tfxMakeShader([*c]const Memory, [*c]const Memory) Shader;
pub fn makeShader(vs: [*c]const Memory, fs: [*c]const Memory) Shader {
    return tfxMakeShader(vs, fs);
}

pub extern fn tfxLoadShader([*c]const u8, [*c]const u8) Shader;
pub fn loadShader(vs: [*c]const u8, fs: [*c]const u8) Shader {
    return tfxLoadShader(vs, fs);
}

pub extern fn tfxSetShader([*c]const Shader) void;
pub fn setShader(shd: [*c]const Shader) void {
    tfxSetShader(shd);
}

pub extern fn tfxReleaseShader([*c]const Shader) void;
pub fn releaseShader(shd: [*c]const Shader) void {
    tfxReleaseShader(shd);
}

pub extern fn tfxUniform1i([*c]const Shader, [*c]const u8, i32) void;
pub fn uniform1i(shd: [*c]const Shader, name: [*c]const u8, v: i32) void {
    tfxUniform1i(shd, name, v);
}

pub extern fn tfxUniform1f([*c]const Shader, [*c]const u8, f32) void;
pub fn uniform1f(shd: [*c]const Shader, name: [*c]const u8, v: f32) void {
    tfxUniform1f(shd, name, v);
}

pub extern fn tfxUniform2f([*c]const Shader, [*c]const u8, f32, f32) void;
pub fn uniform2f(shd: [*c]const Shader, name: [*c]const u8, v0: f32, v1: f32) void {
    tfxUniform2f(shd, name, v0, v1);
}

pub extern fn tfxUniform3f([*c]const Shader, [*c]const u8, f32, f32, f32) void;
pub fn uniform3f(shd: [*c]const Shader, name: [*c]const u8, v0: f32, v1: f32, v2: f32) void {
    tfxUniform3f(shd, name, v0, v1, v2);
}

pub extern fn tfxUniformMat4([*c]const Shader, [*c]const u8, [*c]f32) void;
pub fn uniformMat4(shd: [*c]const Shader, name: [*c]const u8, mat: [*c]f32) void {
    tfxUniformMat4(shd, name, mat);
}

pub extern fn tfxUniformTex([*c]const Shader, [*c]const u8, i32) void;
pub fn uniformTex(shd: [*c]const Shader, name: [*c]const u8, tex: i32) void {
    tfxUniformTex(shd, name, tex);
}

pub const Color = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Pass = extern struct {
    clearFlags: u16 = CLEAR_COLOR,
    clearValue: Color = Color{ .r = 0, .g = 0, .b = 0, .a = 0 },
    framebuffer: RenderTarget = RenderTarget{.{}},
};

pub extern fn tfxInitPass() Pass;
pub fn initPass() Pass {
    return tfxInitPass();
}

pub extern fn tfxBeginPass([*c]Pass) void;
pub fn beginPass(pass: [*c]Pass) void {
    tfxBeginPass(pass);
}

pub extern fn tfxEndPass() void;
pub fn endPass() void {
    tfxEndPass();
}

pub const Pipeline = extern struct {
    depthEnabled: bool = false,
    depthWriteEnabled: bool = false,
    scissorEnabled: bool = false,
    depthCompareFunc: CompareFunc = CompareFunc.NEVER,
    alphaToCoverageEnabled: bool = false,
    blendMode: BlendMode = BlendMode.NONE,
    cullMode: Face = Face.NONE,
    winding: Winding = Winding.CW,
};

pub extern fn tfxSetPipeline([*c]const Pipeline) void;
pub fn setPipeline(pip: [*c]const Pipeline) void {
    tfxSetPipeline(pip);
}
