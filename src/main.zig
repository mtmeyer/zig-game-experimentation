const std = @import("std");
const raylib = @import("raylib");
const ecs = @import("./ecs.zig");

const IsKeyDown = raylib.IsKeyDown;
const Keys = raylib.KeyboardKey;

const speed: f16 = 40;
const gravity: f16 = 9.8;
const friction: f16 = 80;
const jumpVelocity: f16 = 10;

const clampVelocityX: f32 = 8;
const clampVelocityY: f32 = 100;

const velocityDeadZone: f16 = 0.1;

pub const Position = raylib.Vector2;
pub const CollisionRect = raylib.Rectangle;
pub const Velocity = raylib.Vector2;

pub fn main() !void {
    var reg = ecs.Register{};
    reg.init(std.heap.c_allocator);
    defer reg.deinit();

    var testReg = reg.entities;
    _ = testReg;

    _ = try reg.addEntity();

    reg.addComponent(raylib.Vector2, ecs.ComponentTypes.velocity, raylib.Vector2{ .x = 0, .y = 10 });
    reg.addComponent(raylib.Vector2, ecs.ComponentTypes.position, raylib.Vector2{ .x = -100, .y = -50 });
    reg.addComponent(ecs.ComponentDataTypes.position, ecs.ComponentTypes.position, ecs.ComponentDataTypes.position{ .x = -100, .y = -50 });

    std.debug.print("Test print: {}\n", .{reg.entities.items[0]});

    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(800, 800, "hello world!");
    raylib.SetTargetFPS(60);

    const sprite = raylib.LoadTexture("assets/texture/pickle.png");

    defer raylib.CloseWindow();

    var playerCollisionRect: raylib.Rectangle = .{ .x = 0, .y = 0, .width = 0, .height = 0 };

    var isPlayerOnGround = false;

    var velocity: raylib.Vector2 = .{ .x = 0, .y = 0 };
    var pos: raylib.Vector2 = .{ .x = 200, .y = 200 };

    while (!raylib.WindowShouldClose()) {
        var dt = raylib.GetFrameTime();

        const inputDirection = getInputDirection();

        if (velocity.x > 0 and inputDirection.x == 0) {
            velocity.x -= friction * dt;
        } else if (velocity.x < 0 and inputDirection.x == 0) {
            velocity.x += friction * dt;
        }

        if (velocity.x < velocityDeadZone and velocity.x > -velocityDeadZone) {
            velocity.x = 0;
        }

        playerCollisionRect = .{ .x = pos.x, .y = pos.y, .width = @floatFromInt(sprite.width), .height = @floatFromInt(sprite.height) };

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        velocity.x += inputDirection.x * speed * dt;

        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.DrawRectangle(100, 600, 600, 40, raylib.GREEN);

        if (raylib.CheckCollisionRecs(playerCollisionRect, .{ .x = 100, .y = 600, .width = 600, .height = 40 })) {
            isPlayerOnGround = true;
        } else {
            isPlayerOnGround = false;
        }

        if (isPlayerOnGround) {
            velocity.y = 0;

            if (IsKeyDown(.KEY_SPACE)) {
                velocity.y -= jumpVelocity;
            }
        } else {
            velocity.y += gravity * dt;
        }

        var currentPos: raylib.Vector2 = .{ .x = pos.x, .y = pos.y };
        pos = (raylib.Vector2Add(currentPos, clampVelocity(velocity)));

        raylib.DrawTexture(sprite, @intFromFloat(pos.x), @intFromFloat(pos.y), raylib.WHITE);
    }
}

fn getInputDirection() raylib.Vector2 {
    var inputDir: raylib.Vector2 = .{ .x = 0, .y = 0 };

    if (IsKeyDown(.KEY_LEFT)) inputDir.x -= 1;
    if (IsKeyDown(.KEY_RIGHT)) inputDir.x += 1;

    return raylib.Vector2Normalize(inputDir);
}

fn clampVelocity(velocity: raylib.Vector2) raylib.Vector2 {
    var tmp = velocity;
    if (velocity.x > clampVelocityX) {
        tmp.x = clampVelocityX;
    }

    if (velocity.x < -clampVelocityX) {
        tmp.x = -clampVelocityX;
    }

    if (velocity.y > clampVelocityY) {
        tmp.y = clampVelocityY;
    }

    if (velocity.y < -clampVelocityY) {
        tmp.y = -clampVelocityY;
    }

    return tmp;
}
