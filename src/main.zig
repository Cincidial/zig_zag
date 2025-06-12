const std = @import("std");
const sdl = @import("sdl.zig");
const player = @import("player.zig");

const App = struct {
    rendering_window: sdl.RenderingWindow = undefined,

    pub fn init(self: *App) !sdl.Result {
        sdl.logVersion();
        self.rendering_window = try sdl.createWindow("Zig Zag", "0.0.1", "zig_zag", 640, 480);

        return .persist;
    }

    pub fn iterate(self: *App) !sdl.Result {
        // Update
        player.update();

        // Draw
        try self.rendering_window.clear(sdl.Color.init(1, 100, 1, sdl.Color.OPAQUE));
        try player.draw(&self.rendering_window);
        try self.rendering_window.present();

        return .persist;
    }

    pub fn event(_: *App, e: sdl.Event) sdl.Result {
        if (e == .quit) {
            return .success;
        }

        player.event(e);
        return switch (e) {
            .key_down => {
                if (e.key_down.scan_code == sdl.ScanCode.ESCAPE) {
                    sdl.quit();
                    return .success;
                }

                return .persist;
            },
            else => .persist,
        };
    }

    pub fn quit(self: *App, _: sdl.Result) void {
        self.rendering_window.destroy();
        self.rendering_window = undefined;
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
