const std = @import("std");
const raylib = @import("raylib");

const tileSize = 16;

const screenWidth = tileSize * 80;
const screenHeight = tileSize * 45;

const MovementDirection = enum { Up, Down, Left, Right };

fn setupWindow() void {
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = false });
    raylib.InitWindow(screenWidth, screenHeight, "Zig Snek");
    raylib.SetTargetFPS(10);
}

pub fn playGame() !void {
    var snakeSegments = std.ArrayList(raylib.Vector2i).init(std.heap.c_allocator);
    defer snakeSegments.deinit();

    try snakeSegments.append(.{ .x = 96, .y = 96 });
    try snakeSegments.append(.{ .x = 80, .y = 96 });
    try snakeSegments.append(.{ .x = 64, .y = 96 });
    try snakeSegments.append(.{ .x = 64, .y = 80 });
    try snakeSegments.append(.{ .x = 64, .y = 64 });
    try snakeSegments.append(.{ .x = 64, .y = 48 });

    setupWindow();
    defer raylib.CloseWindow();

    var currentMoveDirection = MovementDirection.Right;

    while (!raylib.WindowShouldClose()) {
        var dt = raylib.GetFrameTime();
        _ = dt;

        currentMoveDirection = try moveSnake(&snakeSegments, currentMoveDirection);

        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);

        renderSnake(snakeSegments);
    }
}

fn moveSnake(snakeSegments: *std.ArrayList(raylib.Vector2i), currentMoveDirection: MovementDirection) !MovementDirection {
    var moveChangeVector: raylib.Vector2i = .{ .x = 0, .y = 0 };
    var finalMoveDir: MovementDirection = MovementDirection.Right;

    if (raylib.IsKeyDown(.KEY_W) and currentMoveDirection != MovementDirection.Down) {
        moveChangeVector.y -= 1 * tileSize;
        finalMoveDir = MovementDirection.Up;
    } else if (raylib.IsKeyDown(.KEY_S) and currentMoveDirection != MovementDirection.Up) {
        moveChangeVector.y += 1 * tileSize;
        finalMoveDir = MovementDirection.Down;
    } else if (raylib.IsKeyDown(.KEY_D) and currentMoveDirection != MovementDirection.Left) {
        moveChangeVector.x += 1 * tileSize;
        finalMoveDir = MovementDirection.Right;
    } else if (raylib.IsKeyDown(.KEY_A) and currentMoveDirection != MovementDirection.Right) {
        moveChangeVector.x -= 1 * tileSize;
        finalMoveDir = MovementDirection.Left;
    }

    if (moveChangeVector.x == 0 and moveChangeVector.y == 0) {
        finalMoveDir = currentMoveDirection;
        switch (currentMoveDirection) {
            .Up => {
                moveChangeVector.y -= 1 * tileSize;
            },
            .Down => {
                moveChangeVector.y += 1 * tileSize;
            },
            .Left => {
                moveChangeVector.x -= 1 * tileSize;
            },
            .Right => {
                moveChangeVector.x += 1 * tileSize;
            },
        }
    }

    const newFrontSegment = raylib.Vector2i{ .x = snakeSegments.items[0].x + moveChangeVector.x, .y = snakeSegments.items[0].y + moveChangeVector.y };

    if (snakeSegments.items.len == 1) {
        const newFrontSegmentInsertArray: [1]raylib.Vector2i = .{newFrontSegment};
        try snakeSegments.replaceRange(0, 1, &newFrontSegmentInsertArray);
    } else {
        _ = snakeSegments.pop();
        try snakeSegments.insert(0, newFrontSegment);
    }

    return finalMoveDir;
}

fn renderSnake(snakeSegments: std.ArrayList(raylib.Vector2i)) void {
    for (0..snakeSegments.items.len, snakeSegments.items) |i, segment| {
        if (i == 0) {
            raylib.DrawRectangle(segment.x, segment.y, tileSize, tileSize, raylib.SKYBLUE);
        } else {
            raylib.DrawRectangle(segment.x, segment.y, tileSize, tileSize, raylib.WHITE);
        }
    }
}
