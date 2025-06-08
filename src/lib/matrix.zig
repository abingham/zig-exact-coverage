const dlx = @import("dlx.zig");
const Node = dlx.Node;
const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;

const Matrix = struct {
    header: []Node,
    arena: std.heap.ArenaAllocator,

    pub fn init(num_cols: usize) !Matrix {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const nodes = try arena.allocator().alloc(Node, num_cols + 1);
        var index: usize = 0;
        while (index < num_cols) : (index += 1) {
            nodes[index] = Node {
                .up = &nodes[0],
                .down = &nodes[0],
                .left = &nodes[0],
                .right = &nodes[0],
                .column = &nodes[0],
                .count = 0,
                .id = 0,
            };
        }
        return Matrix{
            .header = nodes,
            .arena = arena
        };
    }

    pub fn deinit(self: Matrix) void {
        self.arena.deinit();
    }
};

test "construct" {
    const matrix = try Matrix.init(10);
    defer matrix.deinit();
    try testing.expect(true);
    // try testing.expect(matrix.ncols == 100);
    // try testing.expect(matrix.nrows == 100);
    // try testing.expect(matrix.data.items.len == 10000);
}
