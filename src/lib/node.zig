const std = @import("std");
const testing = std.testing;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;

const DLXError = error{
    InvalidStateError,
};

pub const Node = struct {
    up: *Node,
    down: *Node,
    left: *Node,
    right: *Node,
    column: *Node,
    id: usize,
    count: usize,

    /// Initialize a node to point at itself.
    pub fn create(allocator: std.mem.Allocator) !*Node {
        var node: *Node = try allocator.create(Node);
        node.init();

        return node;
    }

    /// Initialize node to refer to itself.
    pub fn init(self: *Node) void {
        self.up = self;
        self.down = self;
        self.left = self;
        self.right = self;
        self.column = self;
        self.id = 0;
        self.count = 0;
    }

    /// Insert Node below `above`.
    pub fn insert_v(self: *Node, above: *Node, below: *Node) void {
        self.up = above;
        self.down = below;
        above.down = self;
        below.up = self;
    }

    /// Detach Node from its column.
    pub fn detach_v(self: *Node) void {
        self.up.down = self.down;
        self.down.up = self.up;
    }

    /// (Re)attach Node to its column.
    pub fn attach_v(self: *Node) void {
        self.up.down = self;
        self.down.up = self;
    }

    /// Insert Node between left and right
    pub fn insert_h(self: *Node, left: *Node, right: *Node) void {
        self.left = left;
        self.right = right;
        left.right = self;
        right.left = self;
    }
    /// Remove Node from it's row
    pub fn detach_h(self: *Node) void {
        self.left.right = self.right;
        self.right.left = self.left;
    }

    /// (Re)attach a Node to it's row
    pub fn attach_h(self: *Node) void {
        self.left.right = self;
        self.right.left = self;
    }
};

test "create" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const node = try Node.create(allocator);

    try testing.expect(node.up == node);
}

test "insert_v" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const up = try Node.create(allocator);
    const down = try Node.create(allocator);
    down.insert_v(up, up);

    const in = try Node.create(allocator);

    in.insert_v(up, down);

    try testing.expect(in.up == up);
    try testing.expect(in.down == down);
    try testing.expect(in.left == in);
    try testing.expect(in.right == in);
    try testing.expect(in.column == in);
    try testing.expect(in.id == 0);
    try testing.expect(in.count == 0);

    try testing.expect(up.up == down);
    try testing.expect(up.down == in);
    try testing.expect(up.left == up);
    try testing.expect(up.right == up);
    try testing.expect(up.column == up);
    try testing.expect(up.id == 0);
    try testing.expect(up.count == 0);

    try testing.expect(down.up == in);
    try testing.expect(down.down == up);
    try testing.expect(down.left == down);
    try testing.expect(down.right == down);
    try testing.expect(down.column == down);
    try testing.expect(down.id == 0);
    try testing.expect(down.count == 0);
}

test "detach_v" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const up = try Node.create(allocator);
    const down = try Node.create(allocator);
    down.insert_v(up, up);

    var in = try Node.create(allocator);
    in.insert_v(up, down);
    in.detach_v();

    try testing.expect(in.up == up);
    try testing.expect(in.down == down);
    try testing.expect(in.left == in);
    try testing.expect(in.right == in);
    try testing.expect(in.column == in);
    try testing.expect(in.id == 0);
    try testing.expect(in.count == 0);

    try testing.expect(up.up == down);
    try testing.expect(up.down == down);
    try testing.expect(up.left == up);
    try testing.expect(up.right == up);
    try testing.expect(up.column == up);
    try testing.expect(up.id == 0);
    try testing.expect(up.count == 0);

    try testing.expect(down.up == up);
    try testing.expect(down.down == up);
    try testing.expect(down.left == down);
    try testing.expect(down.right == down);
    try testing.expect(down.column == down);
    try testing.expect(down.id == 0);
    try testing.expect(down.count == 0);
}

test "attach_v" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const up = try Node.create(allocator);
    const down = try Node.create(allocator);
    down.insert_v(up, up);

    var in = try Node.create(allocator);
    in.insert_v(up, down);
    in.detach_v();
    in.attach_v();

    try testing.expect(in.up == up);
    try testing.expect(in.down == down);
    try testing.expect(in.left == in);
    try testing.expect(in.right == in);
    try testing.expect(in.column == in);
    try testing.expect(in.id == 0);
    try testing.expect(in.count == 0);

    try testing.expect(up.up == down);
    try testing.expect(up.down == in);
    try testing.expect(up.left == up);
    try testing.expect(up.right == up);
    try testing.expect(up.column == up);
    try testing.expect(up.id == 0);
    try testing.expect(up.count == 0);

    try testing.expect(down.up == in);
    try testing.expect(down.down == up);
    try testing.expect(down.left == down);
    try testing.expect(down.right == down);
    try testing.expect(down.column == down);
    try testing.expect(down.id == 0);
    try testing.expect(down.count == 0);
}

test "insert_h" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const left = try Node.create(allocator);
    const right = try Node.create(allocator);
    right.insert_h(left, left);

    const in = try Node.create(allocator);
    in.insert_h(left, right);

    try testing.expect(in.up == in);
    try testing.expect(in.down == in);
    try testing.expect(in.left == left);
    try testing.expect(in.right == right);
    try testing.expect(in.column == in);
    try testing.expect(in.id == 0);
    try testing.expect(in.count == 0);

    try testing.expect(left.up == left);
    try testing.expect(left.down == left);
    try testing.expect(left.left == right);
    try testing.expect(left.right == in);
    try testing.expect(left.column == left);
    try testing.expect(left.id == 0);
    try testing.expect(left.count == 0);

    try testing.expect(right.up == right);
    try testing.expect(right.down == right);
    try testing.expect(right.left == in);
    try testing.expect(right.right == left);
    try testing.expect(right.column == right);
    try testing.expect(right.id == 0);
    try testing.expect(right.count == 0);
}

test "detach_h" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const left = try Node.create(allocator);
    const right = try Node.create(allocator);
    right.insert_h(left, left);
    const in = try Node.create(allocator);

    in.insert_h(left, right);
    in.detach_h();

    try testing.expect(in.up == in);
    try testing.expect(in.down == in);
    try testing.expect(in.left == left);
    try testing.expect(in.right == right);
    try testing.expect(in.column == in);
    try testing.expect(in.id == 0);
    try testing.expect(in.count == 0);

    try testing.expect(left.up == left);
    try testing.expect(left.down == left);
    try testing.expect(left.left == right);
    try testing.expect(left.right == right);
    try testing.expect(left.column == left);
    try testing.expect(left.id == 0);
    try testing.expect(left.count == 0);

    try testing.expect(right.up == right);
    try testing.expect(right.down == right);
    try testing.expect(right.left == left);
    try testing.expect(right.right == left);
    try testing.expect(right.column == right);
    try testing.expect(right.id == 0);
    try testing.expect(right.count == 0);
}

test "attach_h" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(gpa_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const left = try Node.create(allocator);
    const right = try Node.create(allocator);
    right.insert_h(left, left);
    const in = try Node.create(allocator);

    in.insert_h(left, right);
    in.detach_h();
    in.attach_h();

    try testing.expect(in.up == in);
    try testing.expect(in.down == in);
    try testing.expect(in.left == left);
    try testing.expect(in.right == right);
    try testing.expect(in.column == in);
    try testing.expect(in.id == 0);
    try testing.expect(in.count == 0);

    try testing.expect(left.up == left);
    try testing.expect(left.down == left);
    try testing.expect(left.left == right);
    try testing.expect(left.right == in);
    try testing.expect(left.column == left);
    try testing.expect(left.id == 0);
    try testing.expect(left.count == 0);

    try testing.expect(right.up == right);
    try testing.expect(right.down == right);
    try testing.expect(right.left == in);
    try testing.expect(right.right == left);
    try testing.expect(right.column == right);
    try testing.expect(right.id == 0);
    try testing.expect(right.count == 0);
}
