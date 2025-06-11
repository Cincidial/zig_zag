const std = @import("std");
const sdl = @import("sdl.zig");

const App = struct {
    rendering_window: sdl.RenderingWindow = undefined,

    pub fn init(self: *App) !sdl.Result {
        sdl.logVersion();
        self.rendering_window = try sdl.createWindow("Zig Zag", "0.0.1", "zig_zag", 640, 480);

        return .persist;
    }

    pub fn iterate(_: *App) sdl.Result {
        return .persist;
    }

    pub fn event(_: *App, e: sdl.Event) sdl.Result {
        return switch (e) {
            .quit => .success,
            else => .persist,
        };
    }

    pub fn quit(self: *App, _: sdl.Result) void {
        self.rendering_window.destroy();
    }
};
var app: App = .{};

pub fn main() !u8 {
    return sdl.start(.{
        .init = struct {
            fn init() anyerror!sdl.Result {
                return app.init();
            }
        }.init,
        .iterate = struct {
            fn iterate() anyerror!sdl.Result {
                return app.iterate();
            }
        }.iterate,
        .event = struct {
            fn event(e: sdl.Event) anyerror!sdl.Result {
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
