const node = @import("node.zig");
const Node = node.Node;

const std = @import("std");
const testing = std.testing;

const Matrix = struct {
    header: *Node,
    columns: []Node,
    arena: std.heap.ArenaAllocator,

    pub fn init(num_cols: usize) !Matrix {
        // TODO: Deal with case where num_cols == max(usize). In that case we can't allocate all of the memory we need.
 
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

        var columns = try arena.allocator().alloc(Node, num_cols);
        
        var header = try arena.allocator().create(Node);
        header.* = Node.init();
        header.right = &columns[0];
        header.left = &columns[num_cols - 1];

        var index: usize = 0;
        while (index < num_cols) : (index += 1) {
            columns[index] = Node{
                .up = &columns[index],
                .down = &columns[index],
                .left = if (index == 0) header else &columns[index - 1],
                .right = if (index == num_cols - 1) header else &columns[index + 1],
                .column = &columns[index],
                .count = 0,
                .id = index,
            };
        }
        return .{ 
            .header = header,
            .columns = columns,
            .arena = arena };
    }

    pub fn deinit(self: Matrix) void {
        self.arena.deinit();
    }

    // pub fn set(self: Matrix, row_index: usize, col_index: usize) !void {
    //     const col = try self.header[col_index + 1];    
    //     const row = col.down;
    //     while (row != col) : (row = row.down) {
    //         // See if the location is already set.
    //         if (row.id == row) {
    //             return;
    //         }
    //
    //         // If we encounter a row node with id > than row_index, we insert above it.
    //         if (row.id > row_index) {
    //             const new_node = try self.arena.allocator().create(Node);  
    //             // new_node.* = .{
    //             //     .up = row.up,
    //             //     .down = row,
    //             //     .left = ...,
    //             //     .right = ...,
    //             //     .column = row.column,
    //             //     .id = row_index,
    //             //     count = 0,
    //             // }
    //         }
    //     }
    // }
};

test "construct" {
    const matrix = try Matrix.init(10);
    defer matrix.deinit();
    // try testing.expect(true);
}
