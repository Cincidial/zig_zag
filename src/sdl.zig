const std = @import("std");
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

pub const Event = union(enum) {
    pub const QuitEvent = c.SDL_QuitEvent;

    quit: QuitEvent,
    unsupported: u32,

    fn from(raw: c.SDL_Event) Event {
        return switch (raw.type) {
            c.SDL_EVENT_QUIT => Event{ .quit = raw.quit },
            else => Event{ .unsupported = raw.type },
        };
    }
};

pub const RenderingWindow = struct {
    window: ?*c.SDL_Window = null,
    renderer: ?*c.SDL_Renderer = null,

    pub fn destroy(self: *RenderingWindow) void {
        if (self.window) |w| {
            c.SDL_DestroyWindow(w);
        }

        if (self.renderer) |r| {
            c.SDL_DestroyRenderer(r);
        }
    }
};

pub const Renderer = struct {};

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
