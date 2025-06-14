const std = @import("std");
const sdl = @import("sdl.zig");
const player = @import("player.zig");
const Rock = @import("rock.zig").Rock;

const init_window_size_width = 640;
const init_window_size_height = 480;

const Entities = union(enum) {
    rock: *Rock,
};

const App = struct {
    allocater: std.mem.Allocator = undefined,
    rendering_window: sdl.RenderingWindow = undefined,
    entities: std.ArrayList(Entities) = undefined,

    pub fn init(self: *App) !sdl.Result {
        sdl.logVersion();
        self.rendering_window = try sdl.createWindow("Zig Zag", "0.0.1", "zig_zag", init_window_size_width, init_window_size_height);
        errdefer self.cleanupWindow();

        self.entities = std.ArrayList(Entities).init(self.allocater);
        errdefer self.cleanupEntities();

        try self.entities.append(.{ .rock = try Rock.alloc(self.allocater) });

        player.event(.{ .window_resized = .{ .width = init_window_size_width, .height = init_window_size_height } });
        return .persist;
    }

    pub fn iterate(self: *App) !sdl.Result {
        // Update
        player.update();

        try self.rendering_window.clear(sdl.Color.init(1, 100, 1, sdl.Color.OPAQUE));
        for (self.entities.items) |value| {
            _ = value.rock.update(); // TODO: Handle cleanup when this is false
            try value.rock.draw(&self.rendering_window);
        }

        // Draw
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
        self.cleanupWindow();
        self.cleanupEntities();
    }

    fn cleanupWindow(self: *App) void {
        self.rendering_window.destroy();
        self.rendering_window = undefined;
    }

    fn cleanupEntities(self: *App) void {
        for (self.entities.items) |value| {
            self.allocater.destroy(value.rock);
        }
        self.entities.deinit();
    }
};
var app: App = .{};

pub fn main() !u8 {
    app.allocater = std.heap.page_allocator;

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
