const c = @cImport({
    @cDefine("SDL_DISABLE_OLD_NAMES", {});
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_revision.h");
    @cDefine("SDL_MAIN_HANDLED", {}); // We provide our own entry point to pass off to zig handlers
    @cInclude("SDL3/SDL_main.h");
});

pub const Result = enum {
    success,
    failure,
    persist, // SDL_Continue, but that's a key word

    fn toSdl(self: Result) c.SDL_AppResult {
        return switch (self) {
            .success => c.SDL_APP_SUCCESS,
            .failure => c.SDL_APP_FAILURE,
            .persist => c.SDL_APP_CONTINUE,
        };
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

pub const SdlAppCallbacks = struct {
    init: *const fn () Result,
    iterate: *const fn () Result,
    event: *const fn (Event) Result,
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
    return app.init().toSdl();
}

fn sdlAppIterateC(_: ?*anyopaque) callconv(.c) c.SDL_AppResult {
    return app.iterate().toSdl();
}

fn sdlAppEventC(_: ?*anyopaque, sdl_event: ?*c.SDL_Event) callconv(.c) c.SDL_AppResult {
    const event = Event.from(sdl_event.?.*);
    switch (event) {
        Event.quit => {
            return c.SDL_APP_SUCCESS;
        },
        else => return c.SDL_APP_CONTINUE,
    }
}

fn sdlAppQuitC(_: ?*anyopaque, result: c.SDL_AppResult) callconv(.c) void {
    app.quit(Result.from(result));
    c.SDL_Quit();
}
