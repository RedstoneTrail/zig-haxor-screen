const std = @import("std");
const vaxis = @import("vaxis");
const file = @embedFile("phrases.txt");

pub fn nanoseconds_to_seconds(nanoseconds: u64) u64 {
    return nanoseconds / std.time.ns_per_s;
}

pub fn seconds_to_nanoseconds(seconds: u64) u64 {
    return seconds * std.time.ns_per_s;
}

pub fn milliseconds_to_nanoseconds(seconds: u64) u64 {
    return seconds * std.time.ns_per_ms;
}

const Event = union(enum) {
    key_press: vaxis.Key,
    winsize: vaxis.Winsize,
    focus_in,
};

const Line = struct {
    name: []const u8,
    progress: u8 = 0,
    random_bias: u64 = 30,
};

pub fn main() !void {
    // vaxis

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    // defer {
    //     const deinit_status = arena.deinit();
    //     if (deinit_status == .leak) {
    //         std.log.err("memory has leaked", .{});
    //     }
    // }

    const allocator = arena.allocator();

    var tty = try vaxis.Tty.init();
    defer tty.deinit();

    var vx = try vaxis.init(allocator, .{});
    defer vx.deinit(allocator, tty.anyWriter());

    var event_loop: vaxis.Loop(Event) = .{
        .tty = &tty,
        .vaxis = &vx,
    };
    try event_loop.init();

    try event_loop.start();
    defer event_loop.stop();

    try vx.enterAltScreen(tty.anyWriter());

    try vx.queryTerminal(tty.anyWriter(), 1 * std.time.ns_per_s);

    // file reading

    var prng = std.Random.DefaultPrng.init(0);
    const random = prng.random();

    comptime var max_name_length: u16 = 0;

    var lines = comptime blk: {
        @setEvalBranchQuota(10000);

        var lines: []const Line = &[_]Line{};
        var it = std.mem.tokenizeScalar(u8, file, '\n');

        while (it.next()) |name| {
            const length: u16 = @intCast(name.len);
            max_name_length = @max(length + 1, max_name_length);
            const line: []const Line = &.{.{ .name = name }};
            lines = lines ++ line;
        }

        var array: [lines.len]Line = undefined;
        @memcpy(&array, lines);
        const array2 = array;
        break :blk array2;
    };

    for (0..lines.len - 1) |line_number| {
        lines[line_number].random_bias = random.intRangeLessThan(u8, 30, 50);
    }

    var ending: bool = false;
    var line_number: u16 = 0;

    line_number += 1;
    switch (event_loop.nextEvent()) {
        .winsize => |ws| vx.resize(allocator, tty.anyWriter(), ws) catch std.debug.panic("could not resize", .{}),
        else => {},
    }

    for (0..lines.len * 100) |_| {
        const window = vx.window();

        // std.time.sleep(random.intRangeLessThan(u64, std.time.ns_per_s / 10, std.time.ns_per_s / 5));
        const time: u64 = std.time.ns_per_s / lines[line_number].random_bias;
        std.time.sleep(time);

        window.clear();

        if (lines[line_number].progress >= 100) {
            line_number += 1;

            if (line_number == lines.len) {
                ending = true;
                break;
            }
        } else {
            // lines[line_number].progress = lines[line_number].progress + random.intRangeLessThan(u8, 5, 15);
            // lines[line_number].progress = lines[line_number].progress + lines[line_number].random_bias / 20;
            lines[line_number].progress += 1;
        }

        window.writeCell(0, window.height - 1, .{ .char = .{ .grapheme = try std.fmt.allocPrint(allocator, "\n{s}", .{lines[line_number].name}) } });

        const bar_width: u16 = window.width - 12 - max_name_length;

        // for (0..@min(lines[line_number].progress, 100)) |progress_usize| {
        //     const progress: u16 = @intCast(progress_usize);
        //     const position: u16 = progress * bar_width / 100;

        //     for (0..4) |repetition_usize| {
        //         const repetition: u16 = @intCast(repetition_usize);

        //         window.writeCell(max_name_length + 3 + position - repetition, window.height - 1, .{ .char = .{ .grapheme = "=" } });
        //     }

        //     window.writeCell(max_name_length + 4 + position, window.height - 1, .{ .char = .{ .grapheme = ">" } });

        //     window.writeCell(window.width - 10, window.height - 1, .{ .char = .{ .grapheme = try std.fmt.allocPrint(allocator, "{}%", .{@min(lines[line_number].progress, 100)}) } });

        //     if (lines[line_number].progress >= 100) {
        //         window.writeCell(window.width - 5, window.height - 1, .{ .char = .{ .grapheme = "DONE" } });
        //     }
        // }

        const progress_bar = try std.fmt.allocPrint(allocator, "[{[arrow]c:=>[width]}", .{ .arrow = '>', .width = bar_width * @min(lines[line_number].progress, 100) / 100 });

        window.writeCell(max_name_length, window.height - 1, .{ .char = .{ .grapheme = progress_bar } });

        const end_of_bar = try std.fmt.allocPrint(allocator, "] {}%", .{@min(lines[line_number].progress, 100)});

        window.writeCell(window.width - 12, window.height - 1, .{ .char = .{ .grapheme = end_of_bar } });

        if (lines[line_number].progress >= 100) {
            window.writeCell(window.width - 5, window.height - 1, .{ .char = .{ .grapheme = "DONE" } });
        }

        if (ending) {
            break;
        }

        vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
    }

    const end_message = "HACK COMPLETE --- REBOOTING IN: ";

    const window = vx.window();

    window.writeCell(0, window.height - 1, .{ .char = .{ .grapheme = try std.fmt.allocPrint(allocator, "\n\n\n{s}3", .{end_message}) } });

    const end_message_len: u16 = @intCast(end_message.len);

    vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
    std.time.sleep(std.time.ns_per_s / 4);

    for (0..3) |dot_number_usize| {
        const dot_number: u16 = @intCast(dot_number_usize);
        window.writeCell(end_message_len + 1 + dot_number, window.height - 1, .{ .char = .{ .grapheme = "." } });

        vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
        std.time.sleep(std.time.ns_per_s / 4);
    }

    window.writeCell(end_message_len + 4, window.height - 1, .{ .char = .{ .grapheme = "2" } });

    vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
    std.time.sleep(std.time.ns_per_s / 4);

    for (0..3) |dot_number_usize| {
        const dot_number: u16 = @intCast(dot_number_usize);
        window.writeCell(end_message_len + 5 + dot_number, window.height - 1, .{ .char = .{ .grapheme = "." } });

        vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
        std.time.sleep(std.time.ns_per_s / 4);
    }

    window.writeCell(end_message_len + 8, window.height - 1, .{ .char = .{ .grapheme = "1" } });

    vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
    std.time.sleep(std.time.ns_per_s / 4);

    for (0..3) |dot_number_usize| {
        const dot_number: u16 = @intCast(dot_number_usize);
        window.writeCell(end_message_len + 9 + dot_number, window.height - 1, .{ .char = .{ .grapheme = "." } });

        vx.render(tty.anyWriter()) catch std.debug.panic("could not render", .{});
        std.time.sleep(std.time.ns_per_s / 4);
    }
}
