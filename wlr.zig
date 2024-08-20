const std = @import("std");

pub const c = struct {
    pub const mint = isize;
    pub const umint = usize;

    ///
    /// Type of an expression in the expression API
    ///
    /// typedef void* wlr_expr;
    pub const wlr_expr = ?*anyopaque;

    /// Enum for the different types of expressions in the expression API
    ///
    /// @remarks A value of this type is returned by the function wlr_ExpressionType
    pub const wlr_expr_t = enum(c_int) {
        WLR_NUMBER = 0,
        WLR_STRING = 1,
        WLR_SYMBOL = 2,
        WLR_NORMAL = 3,
        WLR_ERROR = 4,
        WLR_PACKED_ARRAY = 5,
        WLR_NUMERIC_ARRAY = 6,
        WLR_BOOLEAN_FUNCTION = 7,
        WLR_GRAPH = 8,
        WLR_ASSOCIATION = 9,
        WLR_DISPATCH = 10,
        WLR_REGION = 11,
        WLR_OTHER = 12,
    };

    /// Enum for the different types of errors in the expression API
    ///
    /// @remarks Some expression API functions return a value of this type directly to indicate their status
    ///
    /// @remarks There is a sub-type of expression in the expression API called an "error expression."
    ///
    /// An error expression is returned when an error occurs during the execution of an expression API function that returns an expression.
    /// Every error expression corresponds to a single error type.
    ///
    /// @remarks The function wlr_ErrorType returns the error type of an error expression.
    ///
    /// @remarks WLR_SUCCESS is the lowest value, and WLR_RUNTIME_NOT_STARTED is the highest value.
    ///
    /// The internal implementation of the expression API depends on this fact.
    pub const wlr_err_t = enum(c_int) {
        WLR_SUCCESS = 0,
        WLR_ALLOCATION_ERROR = 1,
        WLR_UNEXPECTED_TYPE = 2,
        WLR_ERROR_EXPRESSION = 3,
        WLR_MISCELLANEOUS_ERROR = 4,
        WLR_OUT_OF_BOUNDS = 5,
        WLR_SIGNING_ERROR = 6,
        WLR_UNSAFE_EXPRESSION = 7,
        WLR_MALFORMED = 8,
        WLR_RUNTIME_NOT_STARTED = 9,
    };

    // WLR_ATTRIBUTE wlr_err_t wlr_ErrorType(wlr_expr errorExpression);
    pub extern fn wlr_ErrorType(error_expression: wlr_expr) wlr_err_t;
    // WLR_ATTRIBUTE wlr_expr_t wlr_ExpressionType(wlr_expr expression);
    pub extern fn wlr_ExpressionType(expression: wlr_expr) wlr_expr_t;
    // wlr_expr wlr_Eval(wlr_expr expression)
    pub extern fn wlr_Eval(expression: wlr_expr) wlr_expr;
    // WLR_ATTRIBUTE wlr_expr wlr_Part(wlr_expr expression, mint index);
    pub extern fn wlr_Part(expression: wlr_expr, index: mint) wlr_expr;
    // WLR_ATTRIBUTE void wlr_Release(void* data);
    pub extern fn wlr_Release(data: ?*anyopaque) void;
    // WLR_ATTRIBUTE wlr_expr wlr_String(const char* string);
    pub extern fn wlr_String(string: [*:0]const u8) wlr_expr;
    // WLR_ATTRIBUTE wlr_err_t wlr_StringData(wlr_expr expression, char** resultData, mint* resultLength);
    pub extern fn wlr_StringData(expression: wlr_expr, resultData: *[*:0]const u8, resultLength: *mint) wlr_err_t;
    // WLR_ATTRIBUTE wlr_expr wlr_Symbol(const char* symbolName);
    pub extern fn wlr_Symbol(symbol_name: [*:0]const u8) wlr_expr;
    // WLR_ATTRIBUTE wlr_expr wlr_VariadicE(void* expressionHead, mint childElementNumber, ...);
    pub extern fn wlr_VariadicE(expression_head: wlr_expr, childElementNumber: mint, ...) callconv(.C) wlr_expr;

    pub const wlr_application_t = enum(c_int) {
        WLR_EXECUTABLE = 0,
        WLR_DYNAMIC_LIBRARY,
    };

    pub const wlr_version_t = enum(c_int) {
        WLR_VERSION_1 = 0,
    };

    pub const wlr_license_t = enum(c_int) {
        WLR_SIGNED_CODE_MODE = 0,
        WLR_LICENSE_OR_SIGNED_CODE_MODE,
    };

    pub const wlr_containment_t = enum(c_int) {
        WLR_CONTAINED = 0,
        WLR_UNCONTAINED,
    };

    pub const wlr_runtime_conf = extern struct {
        argumentCount: mint = 0,
        arguments: *[*:0]const u8 = undefined,
        containmentSetting: wlr_containment_t = wlr_containment_t.WLR_CONTAINED,
    };

    // wlr_err_t wlr_sdk_StartRuntime(wlr_application_t applicationType, wlr_version_t version, wlr_license_t licenseType, const char *layoutDirectory, const wlr_runtime_conf *configuration);
    pub extern fn wlr_sdk_StartRuntime(
        app_type: wlr_application_t,
        version: wlr_version_t,
        license_type: wlr_license_t,
        layout_dir: [*:0]const u8,
        configuration: ?*wlr_runtime_conf,
    ) wlr_err_t;
};

pub const Error = error{
    AllocationError,
    UnexpectedType,
    ErrorExpression,
    MiscellaneousError,
    OutOfBounds,
    SigningError,
    UnsafeExpression,
    Malformed,
    RuntimeNotStarted,
};

fn fromCError(c_error: c.wlr_err_t) Error {
    return switch (c_error) {
        .WLR_SUCCESS => unreachable,
        .WLR_ALLOCATION_ERROR => Error.AllocationError,
        .WLR_UNEXPECTED_TYPE => Error.UnexpectedType,
        .WLR_ERROR_EXPRESSION => Error.ErrorExpression,
        .WLR_MISCELLANEOUS_ERROR => Error.MiscellaneousError,
        .WLR_OUT_OF_BOUNDS => Error.OutOfBounds,
        .WLR_SIGNING_ERROR => Error.SigningError,
        .WLR_UNSAFE_EXPRESSION => Error.UnsafeExpression,
        .WLR_MALFORMED => Error.Malformed,
        .WLR_RUNTIME_NOT_STARTED => Error.RuntimeNotStarted,
    };
}

fn checkCError(c_error: c.wlr_err_t) Error!void {
    if (c_error != c.wlr_err_t.WLR_SUCCESS) {
        return fromCError(c_error);
    }
}

pub const Expr = union(ExprTag) {
    Number: c.wlr_expr,
    String: c.wlr_expr,
    Symbol: c.wlr_expr,
    Normal: c.wlr_expr,
    Error: c.wlr_expr,
    PackedArray: c.wlr_expr,
    NumericArray: c.wlr_expr,
    BooleanFunction: c.wlr_expr,
    Graph: c.wlr_expr,
    Association: c.wlr_expr,
    Dispatch: c.wlr_expr,
    Region: c.wlr_expr,
    Other: c.wlr_expr,

    pub const ExprTag = enum(c_int) {
        Number = @intFromEnum(c.wlr_expr_t.WLR_NUMBER),
        String = @intFromEnum(c.wlr_expr_t.WLR_STRING),
        Symbol = @intFromEnum(c.wlr_expr_t.WLR_SYMBOL),
        Normal = @intFromEnum(c.wlr_expr_t.WLR_NORMAL),
        Error = @intFromEnum(c.wlr_expr_t.WLR_ERROR),
        PackedArray = @intFromEnum(c.wlr_expr_t.WLR_PACKED_ARRAY),
        NumericArray = @intFromEnum(c.wlr_expr_t.WLR_NUMERIC_ARRAY),
        BooleanFunction = @intFromEnum(c.wlr_expr_t.WLR_BOOLEAN_FUNCTION),
        Graph = @intFromEnum(c.wlr_expr_t.WLR_GRAPH),
        Association = @intFromEnum(c.wlr_expr_t.WLR_ASSOCIATION),
        Dispatch = @intFromEnum(c.wlr_expr_t.WLR_DISPATCH),
        Region = @intFromEnum(c.wlr_expr_t.WLR_REGION),
        Other = @intFromEnum(c.wlr_expr_t.WLR_OTHER),
    };

    pub fn wrap(c_expr: c.wlr_expr) !Expr {
        const c_expr_t = c.wlr_ExpressionType(c_expr);
        switch (c_expr_t) {
            .WLR_ERROR => {
                return fromCError(c.wlr_ErrorType(c_expr));
            },
            inline else => |val| {
                const expr_t: ExprTag = @enumFromInt(@intFromEnum(val));
                const expr = @unionInit(Expr, @tagName(expr_t), c_expr);
                return expr;
            },
        }
    }

    pub fn unwrap(self: Expr) c.wlr_expr {
        return switch (self) {
            inline else => |c_expr| c_expr,
        };
    }

    pub fn symbol(str: []const u8) !Expr {
        const c_expr = c.wlr_Symbol(@ptrCast(str));
        const expr = try Expr.wrap(c_expr);
        return expr;
    }

    pub fn string(str: []const u8) !Expr {
        const c_expr = c.wlr_String(@ptrCast(str));
        const expr = try Expr.wrap(c_expr);
        return expr;
    }

    pub fn stringData(self: Expr) ![]const u8 {
        return switch (self) {
            .String => {
                var data: [*:0]const u8 = undefined;
                var len: c.mint = undefined;
                const c_error = c.wlr_StringData(self.unwrap(), &data, &len);
                try checkCError(c_error);
                return data[0..@intCast(len)];
            },
            else => return Error.UnexpectedType,
        };
    }

    pub fn construct(expr_head: Expr, expr_args: anytype) !Expr {
        // switch (@typeInfo(@TypeOf(c_expr_args))) {
        //     .Struct => |struct_info| {
        //         // var expr_args = struct {
        //         //     comptime for (struct_info.fields) |field, i| {
        //         //         @field(i): c.wlr_expr,
        //         //     };
        //         // };
        //         const args_len = struct_info.fields.len;
        //         var expr_args:
        //         inline for (c_expr_args, 0..) |field, i| {
        //             if (@TypeOf(field) != Expr) {
        //                 @compileError("Expected an object of type Expr in the second argument of construct(...)");
        //             }
        //             args_arr[i] =
        //         }

        //         // inline for (struct_info.fields) |field| {
        //         //     const field_value = @field(c_expr_args, field.name);
        //         //     if (@TypeOf(field_value) != Expr) {
        //         //         @compileError("Expected an object of type Expr in the second argument of construct(...)");
        //         //     }
        //         // }
        //     },
        //     else => @compileError("Expected a tuple of Expr objects in the second argument of construct(...)"),
        // }
        const c_expr_head = expr_head.unwrap();
        const args_len = expr_args.len;
        var c_expr_args: std.meta.Tuple(&(.{c.wlr_expr} ** args_len)) = undefined;
        inline for (expr_args, 0..) |expr_arg, i| {
            c_expr_args[i] = expr_arg.unwrap();
        }
        const c_expr = @call(.auto, c.wlr_VariadicE, .{ c_expr_head, args_len } ++ c_expr_args);
        const expr = try Expr.wrap(c_expr);
        return expr;
    }

    pub fn part(self: Expr, index: isize) !Expr {
        return switch (self) {
            .Normal => {
                const c_expr = c.wlr_Part(self.unwrap(), @intCast(index));
                const expr = try Expr.wrap(c_expr);
                return expr;
            },
            else => return Error.UnexpectedType,
        };
    }

    pub fn eval(expr: Expr) !Expr {
        const c_expr = expr.unwrap();
        const new_c_expr = c.wlr_Eval(c_expr);
        const new_expr = try Expr.wrap(new_c_expr);
        return new_expr;
    }
};

pub fn release(obj: anytype) void {
    c.wlr_Release(@constCast(@ptrCast(obj)));
}

pub const SDK = struct {
    pub const ApplicationType = enum(c_int) {
        Executable = @intFromEnum(c.wlr_application_t.WLR_EXECUTABLE),
        DynamicLibrary = @intFromEnum(c.wlr_application_t.WLR_DYNAMIC_LIBRARY),
    };

    pub const LicenseMode = enum(c_int) {
        SignedCode = @intFromEnum(c.wlr_license_t.WLR_SIGNED_CODE_MODE),
        LicenseOrSignedCode = @intFromEnum(c.wlr_license_t.WLR_LICENSE_OR_SIGNED_CODE_MODE),
    };

    pub const ContainmentMode = enum(c_int) {
        Contained = @intFromEnum(c.wlr_containment_t.WLR_CONTAINED),
        Uncontained = @intFromEnum(c.wlr_containment_t.WLR_UNCONTAINED),
    };

    pub const RuntimeConfig = struct {
        app_type: ApplicationType,
        license_mode: LicenseMode = .LicenseOrSignedCode,
        layout_dir: []const u8,
        containment_mode: ContainmentMode = .Uncontained,
    };

    pub fn startRuntime(config: RuntimeConfig) !void {
        const c_app_type: c.wlr_application_t = @enumFromInt(@intFromEnum(config.app_type));
        const c_license_mode: c.wlr_license_t = @enumFromInt(@intFromEnum(config.license_mode));
        const c_layout_dir: [*:0]const u8 = @ptrCast(config.layout_dir);
        const c_containment_mode: c.wlr_containment_t = @enumFromInt(@intFromEnum(config.containment_mode));
        var c_runtime_conf = c.wlr_runtime_conf{
            .containmentSetting = c_containment_mode,
        };
        const c_error = c.wlr_sdk_StartRuntime(
            c_app_type,
            .WLR_VERSION_1,
            c_license_mode,
            c_layout_dir,
            &c_runtime_conf,
        );
        try checkCError(c_error);
    }
};
