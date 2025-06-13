const std = @import("std");
const Vec2 = @import("math.zig").Vec2;
const c = @cImport({
    @cDefine("SDL_DISABLE_OLD_NAMES", {});
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_revision.h");
    @cDefine("SDL_MAIN_HANDLED", {}); // We provide our own entry point to pass off to zig handlers
    @cInclude("SDL3/SDL_main.h");
});

const log = std.log.scoped(.sdl);

/////////////////////////////////////////////
// Wrapper
/////////////////////////////////////////////

inline fn sdlErr(value: anytype) error{SdlError}!switch (@typeInfo(@TypeOf(value))) {
    .bool => void,
    .pointer, .optional => @TypeOf(value.?),
    .int => |info| switch (info.signedness) {
        .signed => @TypeOf(@max(0, value)),
        .unsigned => @TypeOf(value),
    },
    else => @compileError("Cannot check this return type for error: " ++ @typeName(@TypeOf(value))),
} {
    return switch (@typeInfo(@TypeOf(value))) {
        .bool => if (!value) error.SdlError,
        .pointer, .optional => value orelse error.SdlError,
        .int => |info| switch (info.signedness) {
            .signed => if (value >= 0) @max(0, value) else error.SdlError,
            .unsigned => if (value != 0) value else error.SdlError,
        },
        else => comptime unreachable,
    };
}

pub const Result = enum {
    success,
    failure,
    persist, // SDL_Continue, but that's a key word

    fn toSdl(self: anyerror!Result) c.SDL_AppResult {
        if (self) |value| {
            return switch (value) {
                .success => c.SDL_APP_SUCCESS,
                .failure => c.SDL_APP_FAILURE,
                .persist => c.SDL_APP_CONTINUE,
            };
        } else |err| {
            if (err == error.SdlError) {
                log.err("{s}", .{c.SDL_GetError()});
            }

            return c.SDL_APP_FAILURE;
        }
    }

    fn from(raw: c.SDL_AppResult) Result {
        return switch (raw) {
            c.SDL_APP_SUCCESS => .success,
            c.SDL_APP_FAILURE => .failure,
            c.SDL_APP_CONTINUE => .persist,
            else => unreachable,
        };
    }
};

pub const ScanCode = enum(c.SDL_Scancode) {
    UNKNOWN = c.SDL_SCANCODE_UNKNOWN,
    A = c.SDL_SCANCODE_A,
    B = c.SDL_SCANCODE_B,
    C = c.SDL_SCANCODE_C,
    D = c.SDL_SCANCODE_D,
    E = c.SDL_SCANCODE_E,
    F = c.SDL_SCANCODE_F,
    G = c.SDL_SCANCODE_G,
    H = c.SDL_SCANCODE_H,
    I = c.SDL_SCANCODE_I,
    J = c.SDL_SCANCODE_J,
    K = c.SDL_SCANCODE_K,
    L = c.SDL_SCANCODE_L,
    M = c.SDL_SCANCODE_M,
    N = c.SDL_SCANCODE_N,
    O = c.SDL_SCANCODE_O,
    P = c.SDL_SCANCODE_P,
    Q = c.SDL_SCANCODE_Q,
    R = c.SDL_SCANCODE_R,
    S = c.SDL_SCANCODE_S,
    T = c.SDL_SCANCODE_T,
    U = c.SDL_SCANCODE_U,
    V = c.SDL_SCANCODE_V,
    W = c.SDL_SCANCODE_W,
    X = c.SDL_SCANCODE_X,
    Y = c.SDL_SCANCODE_Y,
    Z = c.SDL_SCANCODE_Z,
    N1 = c.SDL_SCANCODE_1,
    N2 = c.SDL_SCANCODE_2,
    N3 = c.SDL_SCANCODE_3,
    N4 = c.SDL_SCANCODE_4,
    N5 = c.SDL_SCANCODE_5,
    N6 = c.SDL_SCANCODE_6,
    N7 = c.SDL_SCANCODE_7,
    N8 = c.SDL_SCANCODE_8,
    N9 = c.SDL_SCANCODE_9,
    N0 = c.SDL_SCANCODE_0,
    RETURN = c.SDL_SCANCODE_RETURN,
    ESCAPE = c.SDL_SCANCODE_ESCAPE,
    BACKSPACE = c.SDL_SCANCODE_BACKSPACE,
    TAB = c.SDL_SCANCODE_TAB,
    SPACE = c.SDL_SCANCODE_SPACE,
    MINUS = c.SDL_SCANCODE_MINUS,
    EQUALS = c.SDL_SCANCODE_EQUALS,
    LEFTBRACKET = c.SDL_SCANCODE_LEFTBRACKET,
    RIGHTBRACKET = c.SDL_SCANCODE_RIGHTBRACKET,
    BACKSLASH = c.SDL_SCANCODE_BACKSLASH,
    NONUSHASH = c.SDL_SCANCODE_NONUSHASH,
    SEMICOLON = c.SDL_SCANCODE_SEMICOLON,
    APOSTROPHE = c.SDL_SCANCODE_APOSTROPHE,
    GRAVE = c.SDL_SCANCODE_GRAVE,
    COMMA = c.SDL_SCANCODE_COMMA,
    PERIOD = c.SDL_SCANCODE_PERIOD,
    SLASH = c.SDL_SCANCODE_SLASH,
    CAPSLOCK = c.SDL_SCANCODE_CAPSLOCK,
    F1 = c.SDL_SCANCODE_F1,
    F2 = c.SDL_SCANCODE_F2,
    F3 = c.SDL_SCANCODE_F3,
    F4 = c.SDL_SCANCODE_F4,
    F5 = c.SDL_SCANCODE_F5,
    F6 = c.SDL_SCANCODE_F6,
    F7 = c.SDL_SCANCODE_F7,
    F8 = c.SDL_SCANCODE_F8,
    F9 = c.SDL_SCANCODE_F9,
    F10 = c.SDL_SCANCODE_F10,
    F11 = c.SDL_SCANCODE_F11,
    F12 = c.SDL_SCANCODE_F12,
    PRINTSCREEN = c.SDL_SCANCODE_PRINTSCREEN,
    SCROLLLOCK = c.SDL_SCANCODE_SCROLLLOCK,
    PAUSE = c.SDL_SCANCODE_PAUSE,
    INSERT = c.SDL_SCANCODE_INSERT,
    HOME = c.SDL_SCANCODE_HOME,
    PAGEUP = c.SDL_SCANCODE_PAGEUP,
    DELETE = c.SDL_SCANCODE_DELETE,
    END = c.SDL_SCANCODE_END,
    PAGEDOWN = c.SDL_SCANCODE_PAGEDOWN,
    RIGHT = c.SDL_SCANCODE_RIGHT,
    LEFT = c.SDL_SCANCODE_LEFT,
    DOWN = c.SDL_SCANCODE_DOWN,
    UP = c.SDL_SCANCODE_UP,
    NUMLOCKCLEAR = c.SDL_SCANCODE_NUMLOCKCLEAR,
    KP_DIVIDE = c.SDL_SCANCODE_KP_DIVIDE,
    KP_MULTIPLY = c.SDL_SCANCODE_KP_MULTIPLY,
    KP_MINUS = c.SDL_SCANCODE_KP_MINUS,
    KP_PLUS = c.SDL_SCANCODE_KP_PLUS,
    KP_ENTER = c.SDL_SCANCODE_KP_ENTER,
    KP_1 = c.SDL_SCANCODE_KP_1,
    KP_2 = c.SDL_SCANCODE_KP_2,
    KP_3 = c.SDL_SCANCODE_KP_3,
    KP_4 = c.SDL_SCANCODE_KP_4,
    KP_5 = c.SDL_SCANCODE_KP_5,
    KP_6 = c.SDL_SCANCODE_KP_6,
    KP_7 = c.SDL_SCANCODE_KP_7,
    KP_8 = c.SDL_SCANCODE_KP_8,
    KP_9 = c.SDL_SCANCODE_KP_9,
    KP_0 = c.SDL_SCANCODE_KP_0,
    KP_PERIOD = c.SDL_SCANCODE_KP_PERIOD,
    NONUSBACKSLASH = c.SDL_SCANCODE_NONUSBACKSLASH,
    APPLICATION = c.SDL_SCANCODE_APPLICATION,
    POWER = c.SDL_SCANCODE_POWER,
    KP_EQUALS = c.SDL_SCANCODE_KP_EQUALS,
    F13 = c.SDL_SCANCODE_F13,
    F14 = c.SDL_SCANCODE_F14,
    F15 = c.SDL_SCANCODE_F15,
    F16 = c.SDL_SCANCODE_F16,
    F17 = c.SDL_SCANCODE_F17,
    F18 = c.SDL_SCANCODE_F18,
    F19 = c.SDL_SCANCODE_F19,
    F20 = c.SDL_SCANCODE_F20,
    F21 = c.SDL_SCANCODE_F21,
    F22 = c.SDL_SCANCODE_F22,
    F23 = c.SDL_SCANCODE_F23,
    F24 = c.SDL_SCANCODE_F24,
    EXECUTE = c.SDL_SCANCODE_EXECUTE,
    HELP = c.SDL_SCANCODE_HELP,
    MENU = c.SDL_SCANCODE_MENU,
    SELECT = c.SDL_SCANCODE_SELECT,
    STOP = c.SDL_SCANCODE_STOP,
    AGAIN = c.SDL_SCANCODE_AGAIN,
    UNDO = c.SDL_SCANCODE_UNDO,
    CUT = c.SDL_SCANCODE_CUT,
    COPY = c.SDL_SCANCODE_COPY,
    PASTE = c.SDL_SCANCODE_PASTE,
    FIND = c.SDL_SCANCODE_FIND,
    MUTE = c.SDL_SCANCODE_MUTE,
    VOLUMEUP = c.SDL_SCANCODE_VOLUMEUP,
    VOLUMEDOWN = c.SDL_SCANCODE_VOLUMEDOWN,
    KP_COMMA = c.SDL_SCANCODE_KP_COMMA,
    KP_EQUALSAS400 = c.SDL_SCANCODE_KP_EQUALSAS400,
    INTERNATIONAL1 = c.SDL_SCANCODE_INTERNATIONAL1,
    INTERNATIONAL2 = c.SDL_SCANCODE_INTERNATIONAL2,
    INTERNATIONAL3 = c.SDL_SCANCODE_INTERNATIONAL3,
    INTERNATIONAL4 = c.SDL_SCANCODE_INTERNATIONAL4,
    INTERNATIONAL5 = c.SDL_SCANCODE_INTERNATIONAL5,
    INTERNATIONAL6 = c.SDL_SCANCODE_INTERNATIONAL6,
    INTERNATIONAL7 = c.SDL_SCANCODE_INTERNATIONAL7,
    INTERNATIONAL8 = c.SDL_SCANCODE_INTERNATIONAL8,
    INTERNATIONAL9 = c.SDL_SCANCODE_INTERNATIONAL9,
    LANG1 = c.SDL_SCANCODE_LANG1,
    LANG2 = c.SDL_SCANCODE_LANG2,
    LANG3 = c.SDL_SCANCODE_LANG3,
    LANG4 = c.SDL_SCANCODE_LANG4,
    LANG5 = c.SDL_SCANCODE_LANG5,
    LANG6 = c.SDL_SCANCODE_LANG6,
    LANG7 = c.SDL_SCANCODE_LANG7,
    LANG8 = c.SDL_SCANCODE_LANG8,
    LANG9 = c.SDL_SCANCODE_LANG9,
    ALTERASE = c.SDL_SCANCODE_ALTERASE,
    SYSREQ = c.SDL_SCANCODE_SYSREQ,
    CANCEL = c.SDL_SCANCODE_CANCEL,
    CLEAR = c.SDL_SCANCODE_CLEAR,
    PRIOR = c.SDL_SCANCODE_PRIOR,
    RETURN2 = c.SDL_SCANCODE_RETURN2,
    SEPARATOR = c.SDL_SCANCODE_SEPARATOR,
    OUT = c.SDL_SCANCODE_OUT,
    OPER = c.SDL_SCANCODE_OPER,
    CLEARAGAIN = c.SDL_SCANCODE_CLEARAGAIN,
    CRSEL = c.SDL_SCANCODE_CRSEL,
    EXSEL = c.SDL_SCANCODE_EXSEL,
    KP_00 = c.SDL_SCANCODE_KP_00,
    KP_000 = c.SDL_SCANCODE_KP_000,
    THOUSANDSSEPARATOR = c.SDL_SCANCODE_THOUSANDSSEPARATOR,
    DECIMALSEPARATOR = c.SDL_SCANCODE_DECIMALSEPARATOR,
    CURRENCYUNIT = c.SDL_SCANCODE_CURRENCYUNIT,
    CURRENCYSUBUNIT = c.SDL_SCANCODE_CURRENCYSUBUNIT,
    KP_LEFTPAREN = c.SDL_SCANCODE_KP_LEFTPAREN,
    KP_RIGHTPAREN = c.SDL_SCANCODE_KP_RIGHTPAREN,
    KP_LEFTBRACE = c.SDL_SCANCODE_KP_LEFTBRACE,
    KP_RIGHTBRACE = c.SDL_SCANCODE_KP_RIGHTBRACE,
    KP_TAB = c.SDL_SCANCODE_KP_TAB,
    KP_BACKSPACE = c.SDL_SCANCODE_KP_BACKSPACE,
    KP_A = c.SDL_SCANCODE_KP_A,
    KP_B = c.SDL_SCANCODE_KP_B,
    KP_C = c.SDL_SCANCODE_KP_C,
    KP_D = c.SDL_SCANCODE_KP_D,
    KP_E = c.SDL_SCANCODE_KP_E,
    KP_F = c.SDL_SCANCODE_KP_F,
    KP_XOR = c.SDL_SCANCODE_KP_XOR,
    KP_POWER = c.SDL_SCANCODE_KP_POWER,
    KP_PERCENT = c.SDL_SCANCODE_KP_PERCENT,
    KP_LESS = c.SDL_SCANCODE_KP_LESS,
    KP_GREATER = c.SDL_SCANCODE_KP_GREATER,
    KP_AMPERSAND = c.SDL_SCANCODE_KP_AMPERSAND,
    KP_DBLAMPERSAND = c.SDL_SCANCODE_KP_DBLAMPERSAND,
    KP_VERTICALBAR = c.SDL_SCANCODE_KP_VERTICALBAR,
    KP_DBLVERTICALBAR = c.SDL_SCANCODE_KP_DBLVERTICALBAR,
    KP_COLON = c.SDL_SCANCODE_KP_COLON,
    KP_HASH = c.SDL_SCANCODE_KP_HASH,
    KP_SPACE = c.SDL_SCANCODE_KP_SPACE,
    KP_AT = c.SDL_SCANCODE_KP_AT,
    KP_EXCLAM = c.SDL_SCANCODE_KP_EXCLAM,
    KP_MEMSTORE = c.SDL_SCANCODE_KP_MEMSTORE,
    KP_MEMRECALL = c.SDL_SCANCODE_KP_MEMRECALL,
    KP_MEMCLEAR = c.SDL_SCANCODE_KP_MEMCLEAR,
    KP_MEMADD = c.SDL_SCANCODE_KP_MEMADD,
    KP_MEMSUBTRACT = c.SDL_SCANCODE_KP_MEMSUBTRACT,
    KP_MEMMULTIPLY = c.SDL_SCANCODE_KP_MEMMULTIPLY,
    KP_MEMDIVIDE = c.SDL_SCANCODE_KP_MEMDIVIDE,
    KP_PLUSMINUS = c.SDL_SCANCODE_KP_PLUSMINUS,
    KP_CLEAR = c.SDL_SCANCODE_KP_CLEAR,
    KP_CLEARENTRY = c.SDL_SCANCODE_KP_CLEARENTRY,
    KP_BINARY = c.SDL_SCANCODE_KP_BINARY,
    KP_OCTAL = c.SDL_SCANCODE_KP_OCTAL,
    KP_DECIMAL = c.SDL_SCANCODE_KP_DECIMAL,
    KP_HEXADECIMAL = c.SDL_SCANCODE_KP_HEXADECIMAL,
    LCTRL = c.SDL_SCANCODE_LCTRL,
    LSHIFT = c.SDL_SCANCODE_LSHIFT,
    LALT = c.SDL_SCANCODE_LALT,
    LGUI = c.SDL_SCANCODE_LGUI,
    RCTRL = c.SDL_SCANCODE_RCTRL,
    RSHIFT = c.SDL_SCANCODE_RSHIFT,
    RALT = c.SDL_SCANCODE_RALT,
    RGUI = c.SDL_SCANCODE_RGUI,
    MODE = c.SDL_SCANCODE_MODE,
    SLEEP = c.SDL_SCANCODE_SLEEP,
    WAKE = c.SDL_SCANCODE_WAKE,
    CHANNEL_INCREMENT = c.SDL_SCANCODE_CHANNEL_INCREMENT,
    CHANNEL_DECREMENT = c.SDL_SCANCODE_CHANNEL_DECREMENT,
    MEDIA_PLAY = c.SDL_SCANCODE_MEDIA_PLAY,
    MEDIA_PAUSE = c.SDL_SCANCODE_MEDIA_PAUSE,
    MEDIA_RECORD = c.SDL_SCANCODE_MEDIA_RECORD,
    MEDIA_FAST_FORWARD = c.SDL_SCANCODE_MEDIA_FAST_FORWARD,
    MEDIA_REWIND = c.SDL_SCANCODE_MEDIA_REWIND,
    MEDIA_NEXT_TRACK = c.SDL_SCANCODE_MEDIA_NEXT_TRACK,
    MEDIA_PREVIOUS_TRACK = c.SDL_SCANCODE_MEDIA_PREVIOUS_TRACK,
    MEDIA_STOP = c.SDL_SCANCODE_MEDIA_STOP,
    MEDIA_EJECT = c.SDL_SCANCODE_MEDIA_EJECT,
    MEDIA_PLAY_PAUSE = c.SDL_SCANCODE_MEDIA_PLAY_PAUSE,
    MEDIA_SELECT = c.SDL_SCANCODE_MEDIA_SELECT,
    AC_NEW = c.SDL_SCANCODE_AC_NEW,
    AC_OPEN = c.SDL_SCANCODE_AC_OPEN,
    AC_CLOSE = c.SDL_SCANCODE_AC_CLOSE,
    AC_EXIT = c.SDL_SCANCODE_AC_EXIT,
    AC_SAVE = c.SDL_SCANCODE_AC_SAVE,
    AC_PRINT = c.SDL_SCANCODE_AC_PRINT,
    AC_PROPERTIES = c.SDL_SCANCODE_AC_PROPERTIES,
    AC_SEARCH = c.SDL_SCANCODE_AC_SEARCH,
    AC_HOME = c.SDL_SCANCODE_AC_HOME,
    AC_BACK = c.SDL_SCANCODE_AC_BACK,
    AC_FORWARD = c.SDL_SCANCODE_AC_FORWARD,
    AC_STOP = c.SDL_SCANCODE_AC_STOP,
    AC_REFRESH = c.SDL_SCANCODE_AC_REFRESH,
    AC_BOOKMARKS = c.SDL_SCANCODE_AC_BOOKMARKS,
    SOFTLEFT = c.SDL_SCANCODE_SOFTLEFT,
    SOFTRIGHT = c.SDL_SCANCODE_SOFTRIGHT,
    CALL = c.SDL_SCANCODE_CALL,
    ENDCALL = c.SDL_SCANCODE_ENDCALL,
    RESERVED = c.SDL_SCANCODE_RESERVED,
    COUNT = c.SDL_SCANCODE_COUNT,
    _,
};

pub const KeyMod = enum(c.SDL_Keymod) {
    NONE = c.SDL_KMOD_NONE,
    LSHIFT = c.SDL_KMOD_LSHIFT,
    RSHIFT = c.SDL_KMOD_RSHIFT,
    LEVEL5 = c.SDL_KMOD_LEVEL5,
    LCTRL = c.SDL_KMOD_LCTRL,
    RCTRL = c.SDL_KMOD_RCTRL,
    LALT = c.SDL_KMOD_LALT,
    RALT = c.SDL_KMOD_RALT,
    LGUI = c.SDL_KMOD_LGUI,
    RGUI = c.SDL_KMOD_RGUI,
    NUM = c.SDL_KMOD_NUM,
    CAPS = c.SDL_KMOD_CAPS,
    MODE = c.SDL_KMOD_MODE,
    SCROLL = c.SDL_KMOD_SCROLL,
    CTRL = c.SDL_KMOD_CTRL,
    SHIFT = c.SDL_KMOD_SHIFT,
    ALT = c.SDL_KMOD_ALT,
    GUI = c.SDL_KMOD_GUI,
    _,
};

pub const KeyDownEvent = struct {
    scan_code: ScanCode,
    mod: KeyMod,
    repeat: bool,
};

pub const KeyUpEvent = struct {
    scan_code: ScanCode,
    mod: KeyMod,
};

pub const WindowResizedEvent = struct {
    width: c.Sint32,
    height: c.Sint32,

    pub inline fn asVec2(self: WindowResizedEvent) Vec2 {
        return .{ .x = @floatFromInt(self.width), .y = @floatFromInt(self.height) };
    }
};

pub const Event = union(enum) {
    pub const QuitEvent = c.SDL_QuitEvent;

    quit: QuitEvent,
    key_down: KeyDownEvent,
    key_up: KeyUpEvent,
    window_resized: WindowResizedEvent,
    unsupported: u32,

    fn from(raw: c.SDL_Event) Event {
        return switch (raw.type) {
            c.SDL_EVENT_QUIT => .{ .quit = raw.quit },
            c.SDL_EVENT_KEY_DOWN => .{ .key_down = .{ .scan_code = @enumFromInt(raw.key.scancode), .mod = @enumFromInt(raw.key.mod), .repeat = raw.key.repeat } },
            c.SDL_EVENT_KEY_UP => .{ .key_up = .{ .scan_code = @enumFromInt(raw.key.scancode), .mod = @enumFromInt(raw.key.mod) } },
            c.SDL_EVENT_WINDOW_RESIZED => .{ .window_resized = .{ .width = raw.window.data1, .height = raw.window.data2 } },
            else => Event{ .unsupported = raw.type },
        };
    }
};

pub const Color = struct {
    pub const OPAQUE = 255;
    pub const TRASPARENT = 0;

    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub inline fn init(r: u8, g: u8, b: u8, a: u8) Color {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    pub inline fn use(self: *const Color, renderer: ?*c.SDL_Renderer) !void {
        try sdlErr(c.SDL_SetRenderDrawColor(renderer, self.r, self.g, self.b, self.a));
    }
};

pub const FRect = struct {
    sdl_frect: c.SDL_FRect = undefined,

    pub inline fn init(x: f32, y: f32, w: f32, h: f32) FRect {
        return .{ .sdl_frect = c.SDL_FRect{ .x = x, .y = y, .w = w, .h = h } };
    }
};

pub const RenderingWindow = struct {
    window: ?*c.SDL_Window = null,
    renderer: ?*c.SDL_Renderer = null,

    pub fn clear(self: *RenderingWindow, color: Color) !void {
        try color.use(self.renderer);
        try sdlErr(c.SDL_RenderClear(self.renderer));
    }

    pub fn fillRect(self: *RenderingWindow, frect: *const FRect, color: Color) !void {
        try color.use(self.renderer);
        return try sdlErr(c.SDL_RenderFillRect(self.renderer, &frect.sdl_frect));
    }

    pub inline fn present(self: *RenderingWindow) !void {
        try sdlErr(c.SDL_RenderPresent(self.renderer));
    }

    pub fn destroy(self: *RenderingWindow) void {
        if (self.window) |w| {
            c.SDL_DestroyWindow(w);
            self.window = null;
        }

        if (self.renderer) |r| {
            c.SDL_DestroyRenderer(r);
            self.renderer = null;
        }
    }
};

pub fn logVersion() void {
    log.debug("SDL buildtime version: {d}.{d}.{d}", .{
        c.SDL_MAJOR_VERSION,
        c.SDL_MINOR_VERSION,
        c.SDL_MICRO_VERSION,
    });
    log.debug("SDL buildtime revision: {s}", .{c.SDL_REVISION});

    const runTimeVersion = c.SDL_GetVersion();
    log.debug("SDL runtime version: {d}.{d}.{d}", .{
        c.SDL_VERSIONNUM_MAJOR(runTimeVersion),
        c.SDL_VERSIONNUM_MINOR(runTimeVersion),
        c.SDL_VERSIONNUM_MICRO(runTimeVersion),
    });
    const revision: [*:0]const u8 = c.SDL_GetRevision();
    log.debug("SDL runtime revision: {s}", .{revision});
}

pub fn createWindow(comptime display_name: []const u8, comptime app_version: []const u8, id: []const u8, width: u16, height: u16) !RenderingWindow {
    try sdlErr(c.SDL_SetAppMetadata(@ptrCast(display_name), @ptrCast(app_version), @ptrCast(id)));
    try sdlErr(c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO | c.SDL_INIT_GAMEPAD));
    sdlErr(c.SDL_SetHint(c.SDL_HINT_RENDER_VSYNC, "1")) catch {};

    var rendering_window: RenderingWindow = .{};
    try sdlErr(c.SDL_CreateWindowAndRenderer("Zig Zag", width, height, 0, @ptrCast(&rendering_window.window), @ptrCast(&rendering_window.renderer)));
    errdefer rendering_window.destroy();

    log.debug("SDL video driver: {s}", .{c.SDL_GetCurrentVideoDriver().?});
    log.debug("SDL audio driver: {s}", .{c.SDL_GetCurrentAudioDriver().?});
    log.debug("SDL renderer: {s}", .{c.SDL_GetRendererName(rendering_window.renderer).?});

    return rendering_window;
}

pub inline fn quit() void {
    c.SDL_Quit();
}

/////////////////////////////////////////////
// App Start
/////////////////////////////////////////////

pub const SdlAppCallbacks = struct {
    init: *const fn () anyerror!Result,
    iterate: *const fn () anyerror!Result,
    event: *const fn (Event) anyerror!Result,
    quit: *const fn (Result) void,
};

var app: SdlAppCallbacks = undefined;
pub fn start(a: SdlAppCallbacks) u8 {
    app = a;

    //app_err.reset();
    var empty_argv: [0:null]?[*:0]u8 = .{};
    const status: u8 = @truncate(@as(c_uint, @bitCast(c.SDL_RunApp(empty_argv.len, @ptrCast(&empty_argv), sdlMainC, null))));

    return status; //return app_err.load() orelse status;
}

fn sdlMainC(argc: c_int, argv: ?[*:null]?[*:0]u8) callconv(.c) c_int {
    return c.SDL_EnterAppMainCallbacks(argc, @ptrCast(argv), sdlAppInitC, sdlAppIterateC, sdlAppEventC, sdlAppQuitC);
}

fn sdlAppInitC(_: ?*?*anyopaque, _: c_int, _: ?[*:null]?[*:0]u8) callconv(.c) c.SDL_AppResult {
    return Result.toSdl(app.init());
}

fn sdlAppIterateC(_: ?*anyopaque) callconv(.c) c.SDL_AppResult {
    return Result.toSdl(app.iterate());
}

fn sdlAppEventC(_: ?*anyopaque, sdl_event: ?*c.SDL_Event) callconv(.c) c.SDL_AppResult {
    const event = Event.from(sdl_event.?.*);
    return Result.toSdl(app.event(event));
}

fn sdlAppQuitC(_: ?*anyopaque, result: c.SDL_AppResult) callconv(.c) void {
    app.quit(Result.from(result));
    c.SDL_Quit();
}
