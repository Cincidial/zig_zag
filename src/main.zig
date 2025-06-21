const std = @import("std");
const sdl = @import("sdl.zig");
const globals = @import("globals.zig");
const math = @import("math.zig");
const player = @import("player.zig");
const bullets = @import("bullets.zig");
const Rock = @import("rock.zig").Rock;

const init_window_size_width = 640;
const init_window_size_height = 640;
var default_rng: std.Random.Xoshiro256 = undefined;

const App = struct {
    rendering_window: sdl.RenderingWindow = undefined,
    rocks: std.ArrayList(Rock) = undefined,

    // TODO: Setup bullets and hazards like below
    // Swap remove from the end - has O(1) removal, supports removal during iteration, remove does not reduce capacity
    // Retains array benifits of locality
    // If things are not put on the heap, then removal has no deallocation (just reduces length). Not on heap though means uniform objects or multiple lists
    pub fn init(self: *App) !sdl.Result {
        sdl.logVersion();
        self.rendering_window = try sdl.createWindow("Zig Zag", "0.0.1", "zig_zag", init_window_size_width, init_window_size_height);
        errdefer self.cleanupWindow();

        _ = try self.event(.{ .window_resized = .{ .width = init_window_size_width, .height = init_window_size_height } });

        self.rocks = std.ArrayList(Rock).init(globals.allocater);
        try self.rocks.appendNTimes(.{}, 200);
        errdefer self.cleanupEntities();

        return .persist;
    }

    pub fn iterate(self: *App) !sdl.Result {
        try self.rendering_window.clear(sdl.Color.init(1, 100, 1, sdl.Color.OPAQUE));
        player.update();
        bullets.update();

        for (self.rocks.items) |*rock| {
            rock.update();
            try rock.draw(&self.rendering_window);
        }

        try bullets.draw(&self.rendering_window);
        try player.draw(&self.rendering_window);
        try self.rendering_window.present();

        return .persist;
    }

    pub fn event(_: *App, e: sdl.Event) !sdl.Result {
        if (e == .quit) {
            return .success;
        }

        try player.event(e);
        return switch (e) {
            .key_down => {
                return switch (e.key_down.scan_code) {
                    .ESCAPE => {
                        sdl.quit();
                        return .success;
                    },
                    else => .persist,
                };
            },
            .window_resized => {
                globals.current_screen = math.Rect.from_vec2(math.Vec2.ZERO, e.window_resized.asVec2());
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
        self.rocks.deinit();
    }
};
var app: App = .{};

pub fn main() !u8 {
    default_rng = std.Random.DefaultPrng.init(std.crypto.random.int(u64));
    globals.allocater = std.heap.page_allocator;
    globals.rng = default_rng.random();

    bullets.init();

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
