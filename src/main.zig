const std = @import("std");
const raylib = @import("raylib");
const IsKeyDown = raylib.IsKeyDown;
const Keys = raylib.KeyboardKey;

const speed: f32 = 3;

pub fn main() void {
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(800, 800, "hello world!");
    raylib.SetTargetFPS(144);

    const sprite = raylib.LoadTexture("assets/texture/pickle.png");

    defer raylib.CloseWindow();

    var pos: raylib.Vector2 = .{ .x = 200, .y = 200 };

    while (!raylib.WindowShouldClose()) {
        const inputDirection = getInputDirection();

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        pos = raylib.Vector2Add(pos, raylib.Vector2Scale(inputDirection, speed));

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.DrawText("hello world!", 100, 100, 20, raylib.YELLOW);
        raylib.DrawTexture(sprite, @intFromFloat(pos.x), @intFromFloat(pos.y), raylib.WHITE);
    }
}

fn getInputDirection() raylib.Vector2 {
    var inputDir: raylib.Vector2 = .{ .x = 0, .y = 0 };
    const frameTime = raylib.GetFrameTime();

    if (IsKeyDown(.KEY_LEFT)) inputDir.x -= 1 * frameTime;
    if (IsKeyDown(.KEY_RIGHT)) inputDir.x += 1 * frameTime;
    if (IsKeyDown(.KEY_UP)) inputDir.y -= 1 * frameTime;
    if (IsKeyDown(.KEY_DOWN)) inputDir.y += 1 * frameTime;

    return raylib.Vector2Normalize(inputDir);
}
