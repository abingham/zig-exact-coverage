const node = @import("node.zig");
const Node = node.Node;

const std = @import("std");
const testing = std.testing;

const Index = struct {
    row: usize,
    col: usize,
};

const Matrix = struct {
    header: *Node,
    columns: []Node,
    arena: std.heap.ArenaAllocator,

    pub fn init(num_cols: usize) !Matrix {
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

    /// Ensure that row_index/col_index is included in the matrix.
    pub fn set(self: Matrix, index: Index) !void {
        const col = try self.columns[index.col];
        const row = col.down;
        while (row != col) : (row = row.down) {
            // See if the location is already set.
            if (row.id == row) {
                return;
            }

            // If we encounter a row node with id > than row_index, we insert above it.
            if (row.id > index.row) {
                const new_node: *Node = try self.arena.allocator().create(Node);  
                new_node.* = .{
                    .up = row.up,
                    .down = row,
                    .left = undefined,
                    .right = undefined,
                    .column = row.column,
                    .id = index.row,
                    .count = 0,
                };

                new_node.left = new_node;
                new_node.right = new_node;

                const left = try self.find_left(index);
                if (left != null) {
                    new_node.left = left;
                    new_node.right = left.right;
                    left.right.left = new_node;
                    left.right = new_node;
                }
            }
        }
    }

    /// Find the node that should be the 'left' of the node at col_index/row_index.
    fn find_left(self: Matrix, index: Index) !?*Node {
        const start_col = try self.columns[index.col];
        var column = start_col.left;
        while (column != start_col) : (column = column.left) {
            var row = column.down;
            while (row != column) : (row = row.down) {
                if (row.id == index.row) {
                    return row;
                }
                else if (row.id > index.row) {
                    break;
                }
            }
        }
        return null;
    }
};

test "construct" {
    const matrix = try Matrix.init(10);
    defer matrix.deinit();
    // try testing.expect(true);
}
