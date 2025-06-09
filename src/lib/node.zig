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

    /// Create a Node that refers to itself, with id=0 and count=0.
    pub fn init() Node {
        var node: Node =  .{
            .up = undefined,
            .down = undefined,
            .left = undefined,
            .right = undefined,
            .column = undefined,
            .id = 0,
            .count = 0,
        };
        node.up = &node;
        node.down = &node;
        node.left = &node;
        node.right = &node;
        node.column = &node;
        return node;
    }
};


