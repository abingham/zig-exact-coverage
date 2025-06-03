//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const matrix = @import("../lib/root.zig").matrix;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("zig_exact_cover_lib");
