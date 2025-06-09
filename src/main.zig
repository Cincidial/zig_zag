const std = @import("std");
const sdl = @import("sdl.zig");

const App = struct {
    pub fn init(_: *const App) sdl.Result {
        return .persist;
    }

    pub fn iterate(_: *const App) sdl.Result {
        return .persist;
    }

    pub fn event(_: *const App, e: sdl.Event) sdl.Result {
        return switch (e) {
            .quit => .success,
            else => .persist,
        };
    }

    pub fn quit(_: *const App, _: sdl.Result) void {}
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
