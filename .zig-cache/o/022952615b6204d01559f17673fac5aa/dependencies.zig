pub const packages = struct {
    pub const @"vaxis-0.1.0-BWNV_O8OCQBC4w-MnOGaKw9zFVFgTxf3XfcvgScUagEJ" = struct {
        pub const build_root = "/home/redstonetrail/.cache/zig/p/vaxis-0.1.0-BWNV_O8OCQBC4w-MnOGaKw9zFVFgTxf3XfcvgScUagEJ";
        pub const build_zig = @import("vaxis-0.1.0-BWNV_O8OCQBC4w-MnOGaKw9zFVFgTxf3XfcvgScUagEJ");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "zigimg", "zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj" },
            .{ "zg", "zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM" },
        };
    };
    pub const @"zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM" = struct {
        pub const build_root = "/home/redstonetrail/.cache/zig/p/zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM";
        pub const build_zig = @import("zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj" = struct {
        pub const build_root = "/home/redstonetrail/.cache/zig/p/zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj";
        pub const build_zig = @import("zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "vaxis", "vaxis-0.1.0-BWNV_O8OCQBC4w-MnOGaKw9zFVFgTxf3XfcvgScUagEJ" },
};
