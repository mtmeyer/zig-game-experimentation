const std = @import("std");
const raylib = @import("raylib");

const tileSize = 16;

const screenWidth = tileSize * 80;
const screenHeight = tileSize * 45;

const MovementDirection = enum { Up, Down, Left, Right, None };

fn setupWindow() void {
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = false });
    raylib.InitWindow(screenWidth, screenHeight, "Zig Snek");
    raylib.SetTargetFPS(60);
}

pub fn playGame() !void {
    var snakeSegments = std.ArrayList(raylib.Vector2i).init(std.heap.c_allocator);
    defer snakeSegments.deinit();

    var snack: raylib.Vector2i = .{ .x = 960, .y = 480 };

    try snakeSegments.append(.{ .x = 96, .y = 96 });
    try snakeSegments.append(.{ .x = 80, .y = 96 });
    try snakeSegments.append(.{ .x = 64, .y = 96 });
    try snakeSegments.append(.{ .x = 64, .y = 80 });
    try snakeSegments.append(.{ .x = 64, .y = 64 });
    try snakeSegments.append(.{ .x = 64, .y = 48 });
    try snakeSegments.append(.{ .x = 80, .y = 48 });
    try snakeSegments.append(.{ .x = 96, .y = 48 });

    setupWindow();
    defer raylib.CloseWindow();

    var currentMoveDirection = MovementDirection.Right;
    var playerInputDirection = MovementDirection.None;

    // Arbitrary high number to satisfy if loop on game launch
    var timeSinceLastTick: f32 = 100.0;

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        var dt = raylib.GetFrameTime();

        const tickRate: f32 = dt * 5;
        raylib.DrawFPS(10, 10);

        raylib.ClearBackground(raylib.BLACK);

        playerInputDirection = getPlayerInput(playerInputDirection);

        if (timeSinceLastTick >= tickRate) {
            currentMoveDirection = try moveSnake(&snakeSegments, currentMoveDirection, playerInputDirection);

            timeSinceLastTick = 0;
        } else {
            timeSinceLastTick += dt;
        }

        handleCollisionsWithSelf(&snakeSegments);
        snack = try handleCollisionWithSnack(&snakeSegments, snack);

        renderSnake(&snakeSegments);

        raylib.DrawRectangle(snack.x, snack.y, tileSize, tileSize, raylib.LIME);
    }
}

fn getPlayerInput(playerInputDirection: MovementDirection) MovementDirection {
    if (raylib.IsKeyDown(.KEY_W)) {
        return MovementDirection.Up;
    } else if (raylib.IsKeyDown(.KEY_S)) {
        return MovementDirection.Down;
    } else if (raylib.IsKeyDown(.KEY_D)) {
        return MovementDirection.Right;
    } else if (raylib.IsKeyDown(.KEY_A)) {
        return MovementDirection.Left;
    } else {
        return playerInputDirection;
    }
}

fn moveSnake(snakeSegments: *std.ArrayList(raylib.Vector2i), currentMoveDirection: MovementDirection, playerInputDirection: MovementDirection) !MovementDirection {
    var moveChangeVector: raylib.Vector2i = .{ .x = 0, .y = 0 };
    var finalMoveDir: MovementDirection = MovementDirection.Right;

    switch (playerInputDirection) {
        .Up => {
            if (currentMoveDirection != MovementDirection.Down) {
                moveChangeVector.y -= 1 * tileSize;
                finalMoveDir = MovementDirection.Up;
            }
        },
        .Down => {
            if (currentMoveDirection != MovementDirection.Up) {
                moveChangeVector.y += 1 * tileSize;
                finalMoveDir = MovementDirection.Down;
            }
        },
        .Left => {
            if (currentMoveDirection != MovementDirection.Right) {
                moveChangeVector.x -= 1 * tileSize;
                finalMoveDir = MovementDirection.Left;
            }
        },
        .Right => {
            if (currentMoveDirection != MovementDirection.Left) {
                moveChangeVector.x += 1 * tileSize;
                finalMoveDir = MovementDirection.Right;
            }
        },
        .None => {
            finalMoveDir = currentMoveDirection;
        },
    }

    if (moveChangeVector.x == 0 and moveChangeVector.y == 0) {
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
            .None => {},
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

fn renderSnake(snakeSegments: *std.ArrayList(raylib.Vector2i)) void {
    for (0..snakeSegments.items.len, snakeSegments.items) |i, segment| {
        if (i == 0) {
            raylib.DrawRectangle(segment.x, segment.y, tileSize, tileSize, raylib.SKYBLUE);
        } else {
            raylib.DrawRectangle(segment.x, segment.y, tileSize, tileSize, raylib.WHITE);
        }
    }
}

fn handleCollisionsWithSelf(snakeSegments: *std.ArrayList(raylib.Vector2i)) void {
    // Snake can only collide with itself after 4 segments exist
    if (snakeSegments.items.len < 5) {
        return;
    }

    const snakeHead: raylib.Rectangle = rect(snakeSegments.items[0]);

    for (0..snakeSegments.items.len, snakeSegments.items) |i, segment| {
        if (i < 4) {
            continue;
        }
        const hasCollided = raylib.CheckCollisionRecs(snakeHead, rect(segment));
        if (hasCollided) {
            gameOver();
        }
    }
}

fn handleCollisionWithSnack(snakeSegments: *std.ArrayList(raylib.Vector2i), snack: raylib.Vector2i) !raylib.Vector2i {
    const head = snakeSegments.items[0];
    if (raylib.CheckCollisionRecs(rect(head), rect(snack))) {
        const lastSegment = snakeSegments.items[snakeSegments.items.len - 1];
        const secondLastSegment = snakeSegments.items[snakeSegments.items.len - 2];
        const diff: raylib.Vector2i = .{ .x = lastSegment.x - secondLastSegment.x, .y = lastSegment.y - secondLastSegment.y };

        const newSegment: raylib.Vector2i = .{ .x = lastSegment.x + diff.x, .y = lastSegment.y + diff.y };

        try snakeSegments.append(newSegment);

        return .{ .x = -100, .y = -100 };
    } else {
        return snack;
    }
}

fn gameOver() void {
    std.debug.print("Game Over", .{});
    // raylib.CloseWindow();
}

fn rect(vector: raylib.Vector2i) raylib.Rectangle {
    const returnValue: raylib.Rectangle = .{ .x = @floatFromInt(vector.x), .y = @floatFromInt(vector.y), .width = tileSize, .height = tileSize };
    return returnValue;
}
