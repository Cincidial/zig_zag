const std = @import("std");
const sdl = @import("sdl.zig");

const App = struct {
    pub fn init(_: *const App) sdl.Result {
        std.debug.print("init", .{});
        return .persist;
    }

    pub fn iterate(_: *const App) sdl.Result {
        std.debug.print("iterate", .{});
        return .persist;
    }

    pub fn event(_: *const App, _: sdl.Event) sdl.Result {
        std.debug.print("event", .{});
        return .persist;
    }

    pub fn quit(_: *const App, _: sdl.Result) void {
        std.debug.print("quit", .{});
    }
};
const app: App = .{};

pub fn main() !u8 {
    return sdl.start(.{
        .init = struct {
            fn init() sdl.Result {
                return app.init();
            }
        }.init,
        .iterate = struct {
            fn iterate() sdl.Result {
                return app.iterate();
            }
        }.iterate,
        .event = struct {
            fn event(e: sdl.Event) sdl.Result {
                return app.event(e);
            }
        }.event,
        .quit = struct {
            fn quit(r: sdl.Result) void {
                app.quit(r);
            }
        }.quit,
    });
}
