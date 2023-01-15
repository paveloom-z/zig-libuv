const std = @import("std");

const uv = @import("lib.zig");

const Buf = uv.Buf;
const Cast = uv.Cast;
const File = uv.File;
const Loop = uv.Loop;
const OsFd = uv.OsFd;
const Req = uv.Req;
const ReqDecls = uv.ReqDecls;
const c = uv.c;
const check = uv.check;

/// Kind of a `copyfile` operation
pub usingnamespace struct {
    pub const FS_COPYFILE_EXCL = c.UV_FS_COPYFILE_EXCL;
    pub const FS_COPYFILE_FICLONE = c.UV_FS_COPYFILE_FICLONE;
    pub const FS_COPYFILE_FICLONE_FORCE = c.UV_FS_COPYFILE_FICLONE_FORCE;
};

/// File system request
pub const Fs = extern struct {
    const Self = @This();
    pub const UV = c.uv_fs_t;
    pub const FsCallback = ?fn (*Self) callconv(.C) void;
    pub const FsCallbackUV = c.uv_fs_cb;
    data: ?*anyopaque,
    type: Req.Type,
    reserved: [6]?*anyopaque,
    fs_type: c_int,
    loop: *Loop,
    cb: FsCallbackUV,
    result: isize,
    ptr: ?*anyopaque,
    path: ?[*:0]const u8,
    statbuf: Stat.UV,
    new_path: ?[*:0]const u8,
    file: File,
    flags: c_int,
    mode: c.mode_t,
    nbufs: c_uint,
    bufs: *Buf,
    off: c.off_t,
    uid: c.uv_uid_t,
    gid: c.uv_gid_t,
    atime: f64,
    mtime: f64,
    work_req: c.struct_uv__work,
    bufsml: [4]Buf,
    usingnamespace Cast(Self);
    usingnamespace ReqDecls;
    /// Cleanup request
    pub fn cleanup(self: *Self) void {
        c.uv_fs_req_cleanup(self.toUV());
    }
    /// Close a file descriptor
    pub fn close(
        self: *Self,
        loop: *Loop,
        file: File,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_close(
            loop.toUV(),
            self.toUV(),
            file,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Open and possibly create a file
    pub fn open(
        self: *Self,
        loop: *Loop,
        path: ?[*:0]const u8,
        flags: c_int,
        mode: c_int,
        cb: FsCallback,
    ) !c_int {
        const res = c.uv_fs_open(
            loop.toUV(),
            self.toUV(),
            path,
            flags,
            mode,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
        return res;
    }
    /// Read or write data into multiple buffers
    pub fn read(
        self: *Self,
        loop: *Loop,
        file: File,
        bufs: *const Buf,
        nbufs: c_uint,
        offset: i64,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_read(
            loop.toUV(),
            self.toUV(),
            file,
            bufs.toConstUV(),
            nbufs,
            offset,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Delete a name and possibly the file it refers to
    pub fn unlink(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_unlink(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Read or write data into multiple buffers
    pub fn write(
        self: *Self,
        loop: *Loop,
        file: File,
        bufs: *const Buf,
        nbufs: c_uint,
        offset: i64,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_write(
            loop.toUV(),
            self.toUV(),
            file,
            bufs.toConstUV(),
            nbufs,
            offset,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Create a directory
    pub fn mkdir(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        mode: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_mkdir(
            loop.toUV(),
            self.toUV(),
            path,
            mode,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Create a unique temporary directory
    pub fn mkdtemp(
        self: *Self,
        loop: *Loop,
        tpl: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_mkdtemp(
            loop.toUV(),
            self.toUV(),
            tpl,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Create a unique temporary file
    pub fn mkstemp(
        self: *Self,
        loop: *Loop,
        tpl: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_mkstemp(
            loop.toUV(),
            self.toUV(),
            tpl,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Delete a directory
    pub fn rmdir(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_rmdir(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Open path as a directory stream
    pub fn opendir(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_opendir(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Close the directory stream
    pub fn closedir(
        self: *Self,
        loop: *Loop,
        dir: *Dir,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_closedir(
            loop.toUV(),
            self.toUV(),
            dir,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Iterate over the directory stream
    pub fn readdir(
        self: *Self,
        loop: *Loop,
        dir: *Dir,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_readdir(
            loop.toUV(),
            self.toUV(),
            dir,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Scan a directory for matching entries
    pub fn scandir(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        flags: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_scandir(
            loop.toUV(),
            self.toUV(),
            path,
            flags,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Scan a directory for matching entries (slightly different API)
    pub fn scandirNext(self: *Self, ent: *DirEnt) !void {
        const res = c.uv_fs_scandir_next(self.toUV(), ent);
        try check(res);
    }
    /// Get file status
    pub fn stat(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_stat(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Get file status
    pub fn fstat(
        self: *Self,
        loop: *Loop,
        file: File,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_fstat(
            loop.toUV(),
            self.toUV(),
            file,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Get file status
    pub fn lstat(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_lstat(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Get filesystem statistics
    pub fn statfs(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_statfs(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change the name or location of a file
    pub fn rename(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        new_path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_rename(
            loop.toUV(),
            self.toUV(),
            path,
            new_path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Synchronize a file's in-core state with storage device
    pub fn fsync(
        self: *Self,
        loop: *Loop,
        file: File,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_fsync(
            loop.toUV(),
            self.toUV(),
            file,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Synchronize a file's in-core state with storage device
    pub fn fdatasync(
        self: *Self,
        loop: *Loop,
        file: File,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_fdatasync(
            loop.toUV(),
            self.toUV(),
            file,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Truncate a file to a specified length
    pub fn ftruncate(
        self: *Self,
        loop: *Loop,
        file: File,
        offset: i64,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_ftruncate(
            loop.toUV(),
            self.toUV(),
            file,
            offset,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Copy a file from path to new_path
    pub fn copyfile(
        self: *Self,
        loop: *Loop,
        path: [*c]const u8,
        new_path: [*c]const u8,
        flags: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_copyfile(
            loop.toUV(),
            self.toUV(),
            path,
            new_path,
            flags,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Transfer data between file descriptors
    pub fn sendfile(
        self: *Self,
        loop: *Loop,
        out_fd: File,
        in_fd: File,
        in_offset: i64,
        length: usize,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_sendfile(
            loop.toUV(),
            self.toUV(),
            out_fd,
            in_fd,
            in_offset,
            length,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Check user's permissions for a file
    pub fn access(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        mode: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_access(
            loop.toUV(),
            self.toUV(),
            path,
            mode,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change file mode bits
    pub fn chmod(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        mode: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_chmod(
            loop.toUV(),
            self.toUV(),
            path,
            mode,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change file mode bits
    pub fn fchmod(
        self: *Self,
        loop: *Loop,
        file: File,
        mode: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_fchmod(
            loop.toUV(),
            self.toUV(),
            file,
            mode,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change file last access and modification times
    pub fn utime(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        atime: f64,
        mtime: f64,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_utime(
            loop.toUV(),
            self.toUV(),
            path,
            atime,
            mtime,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change file timestamps
    pub fn futime(
        self: *Self,
        loop: *Loop,
        file: File,
        atime: f64,
        mtime: f64,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_futime(
            loop.toUV(),
            self.toUV(),
            file,
            atime,
            mtime,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change file timestamps
    pub fn lutime(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        atime: f64,
        mtime: f64,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_lutime(
            loop.toUV(),
            self.toUV(),
            path,
            atime,
            mtime,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Make a new name for a file
    pub fn link(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        new_path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_link(
            loop.toUV(),
            self.toUV(),
            path,
            new_path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Make a new name for a file
    pub fn symlink(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        new_path: ?*const u8,
        flags: c_int,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_symlink(
            loop.toUV(),
            self.toUV(),
            path,
            new_path,
            flags,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Read value of a symbolic link
    pub fn readlink(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_readlink(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Return the canonicalized absolute pathname
    pub fn realpath(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_realpath(
            loop.toUV(),
            self.toUV(),
            path,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change ownership of a file
    pub fn chown(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        uid: c.uv_uid_t,
        gid: c.uv_gid_t,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_chown(
            loop.toUV(),
            self.toUV(),
            path,
            uid,
            gid,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change ownership of a file
    pub fn fchown(
        self: *Self,
        loop: *Loop,
        file: File,
        uid: c.uv_uid_t,
        gid: c.uv_gid_t,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_fchown(
            loop.toUV(),
            self.toUV(),
            file,
            uid,
            gid,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
    /// Change ownership of a file
    pub fn lchown(
        self: *Self,
        loop: *Loop,
        path: ?*const u8,
        uid: c.uv_uid_t,
        gid: c.uv_gid_t,
        cb: FsCallback,
    ) !void {
        const res = c.uv_fs_lchown(
            loop.toUV(),
            self.toUV(),
            path,
            uid,
            gid,
            @ptrCast(FsCallbackUV, cb),
        );
        try check(res);
    }
};

/// Portable equivalent of `struct timespec`
pub const TimeSpec = extern struct {
    const Self = @This();
    pub const UV = c.uv_timespec_t;
    tv_sec: c_long,
    tv_nsec: c_long,
    usingnamespace Cast(Self);
};

/// Portable equivalent of `struct stat`
pub const Stat = extern struct {
    const Self = @This();
    pub const UV = c.uv_stat_t;
    st_dev: u64,
    st_mode: u64,
    st_nlink: u64,
    st_uid: u64,
    st_gid: u64,
    st_rdev: u64,
    st_ino: u64,
    st_size: u64,
    st_blksize: u64,
    st_blocks: u64,
    st_flags: u64,
    st_gen: u64,
    st_atim: TimeSpec,
    st_mtim: TimeSpec,
    st_ctim: TimeSpec,
    st_birthtim: TimeSpec,
    usingnamespace Cast(Self);
};

/// File system request type
pub usingnamespace struct {
    pub const FS_ACCESS = c.UV_FS_ACCESS;
    pub const FS_CHMOD = c.UV_FS_CHMOD;
    pub const FS_CHOWN = c.UV_FS_CHOWN;
    pub const FS_CLOSE = c.UV_FS_CLOSE;
    pub const FS_CLOSEDIR = c.UV_FS_CLOSEDIR;
    pub const FS_COPYFILE = c.UV_FS_COPYFILE;
    pub const FS_CUSTOM = c.UV_FS_CUSTOM;
    pub const FS_FCHMOD = c.UV_FS_FCHMOD;
    pub const FS_FCHOWN = c.UV_FS_FCHOWN;
    pub const FS_FDATASYNC = c.UV_FS_FDATASYNC;
    pub const FS_FSTAT = c.UV_FS_FSTAT;
    pub const FS_FSYNC = c.UV_FS_FSYNC;
    pub const FS_FTRUNCATE = c.UV_FS_FTRUNCATE;
    pub const FS_FUTIME = c.UV_FS_FUTIME;
    pub const FS_LCHOWN = c.UV_FS_LCHOWN;
    pub const FS_LINK = c.UV_FS_LINK;
    pub const FS_LSTAT = c.UV_FS_LSTAT;
    pub const FS_LUTIME = c.UV_FS_LUTIME;
    pub const FS_MKDIR = c.UV_FS_MKDIR;
    pub const FS_MKDTEMP = c.UV_FS_MKDTEMP;
    pub const FS_MKSTEMP = c.UV_FS_MKSTEMP;
    pub const FS_OPEN = c.UV_FS_OPEN;
    pub const FS_OPENDIR = c.UV_FS_OPENDIR;
    pub const FS_READ = c.UV_FS_READ;
    pub const FS_READDIR = c.UV_FS_READDIR;
    pub const FS_READLINK = c.UV_FS_READLINK;
    pub const FS_REALPATH = c.UV_FS_REALPATH;
    pub const FS_RENAME = c.UV_FS_RENAME;
    pub const FS_RMDIR = c.UV_FS_RMDIR;
    pub const FS_SCANDIR = c.UV_FS_SCANDIR;
    pub const FS_SENDFILE = c.UV_FS_SENDFILE;
    pub const FS_STAT = c.UV_FS_STAT;
    pub const FS_STATFS = c.UV_FS_STATFS;
    pub const FS_SYMLINK = c.UV_FS_SYMLINK;
    pub const FS_UNKNOWN = c.UV_FS_UNKNOWN;
    pub const FS_UNLINK = c.UV_FS_UNLINK;
    pub const FS_UTIME = c.UV_FS_UTIME;
    pub const FS_WRITE = c.UV_FS_WRITE;
};

/// Reduced cross platform equivalent of `struct statfs`
pub const StatFS = extern struct {
    const Self = @This();
    pub const UV = c.uv_statfs_t;
    f_type: u64,
    f_bsize: u64,
    f_blocks: u64,
    f_bfree: u64,
    f_bavail: u64,
    f_files: u64,
    f_ffree: u64,
    f_spare: [4]u64,
    usingnamespace Cast(Self);
};

/// Cross platform (reduced) equivalent of `struct dirent`
pub const DirEnt = extern struct {
    const Type = c.uv_dirent_type_t;
    const Self = @This();
    pub const UV = c.uv_dirent_t;
    name: ?[*:0]const u8,
    type: Type,
    usingnamespace Cast(Self);
};

/// Type of a `DirEnt`
pub usingnamespace struct {
    pub const DIRENT_BLOCK = c.UV_DIRENT_BLOCK;
    pub const DIRENT_CHAR = c.UV_DIRENT_CHAR;
    pub const DIRENT_DIR = c.UV_DIRENT_DIR;
    pub const DIRENT_FIFO = c.UV_DIRENT_FIFO;
    pub const DIRENT_FILE = c.UV_DIRENT_FILE;
    pub const DIRENT_LINK = c.UV_DIRENT_LINK;
    pub const DIRENT_SOCKET = c.UV_DIRENT_SOCKET;
    pub const DIRENT_UNKNOWN = c.UV_DIRENT_UNKNOWN;
};

/// Data type used for streaming directory iteration
pub const Dir = extern struct {
    const Self = @This();
    pub const UV = c.uv_dir_t;
    dirents: *DirEnt,
    nentries: usize,
    reserved: [4]?*anyopaque,
    dir: ?*c.DIR,
    usingnamespace Cast(Self);
};

/// For a file descriptor in the C runtime, get the OS-dependent handle
pub fn getOSFHandle(fd: c_int) OsFd {
    return c.uv_get_osfhandle(fd);
}

/// For a OS-dependent handle, get the file descriptor in the C runtime
pub fn openOSFHandle(os_fd: OsFd) !void {
    const res = c.uv_open_osfhandle(os_fd);
    try check(res);
}

/// Open modes
pub usingnamespace struct {
    pub const S_IEXEC = c.S_IEXEC;
    pub const S_IREAD = c.S_IREAD;
    pub const S_IRGRP = c.S_IRGRP;
    pub const S_IROTH = c.S_IROTH;
    pub const S_IRUSR = c.S_IRUSR;
    pub const S_IRWXG = c.S_IRWXG;
    pub const S_IRWXO = c.S_IRWXO;
    pub const S_IRWXU = c.S_IRWXU;
    pub const S_ISGID = c.S_ISGID;
    pub const S_ISUID = c.S_ISUID;
    pub const S_ISVTX = c.S_ISVTX;
    pub const S_IWGRP = c.S_IWGRP;
    pub const S_IWOTH = c.S_IWOTH;
    pub const S_IWRITE = c.S_IWRITE;
    pub const S_IWUSR = c.S_IWUSR;
    pub const S_IXGRP = c.S_IXGRP;
    pub const S_IXOTH = c.S_IXOTH;
    pub const S_IXUSR = c.S_IXUSR;
};

/// `open`'s flags
pub usingnamespace struct {
    pub const O_ACCMODE = c.O_ACCMODE;
    pub const O_APPEND = c.O_APPEND;
    pub const O_ASYNC = c.O_ASYNC;
    pub const O_CLOEXEC = c.O_CLOEXEC;
    pub const O_CREAT = c.O_CREAT;
    pub const O_DIRECTORY = c.O_DIRECTORY;
    pub const O_DSYNC = c.O_DSYNC;
    pub const O_EXCL = c.O_EXCL;
    pub const O_FSYNC = c.O_FSYNC;
    pub const O_NDELAY = c.O_NDELAY;
    pub const O_NOCTTY = c.O_NOCTTY;
    pub const O_NOFOLLOW = c.O_NOFOLLOW;
    pub const O_NONBLOCK = c.O_NONBLOCK;
    pub const O_RDONLY = c.O_RDONLY;
    pub const O_RDWR = c.O_RDWR;
    pub const O_RSYNC = c.O_RSYNC;
    pub const O_SYNC = c.O_SYNC;
    pub const O_TRUNC = c.O_TRUNC;
    pub const O_WRONLY = c.O_WRONLY;
};

/// `libuv's open flags
pub usingnamespace struct {
    pub const FS_O_APPEND = c.UV_FS_O_APPEND;
    pub const FS_O_CREAT = c.UV_FS_O_CREAT;
    pub const FS_O_DIRECT = c.UV_FS_O_DIRECT;
    pub const FS_O_DIRECTORY = c.UV_FS_O_DIRECTORY;
    pub const FS_O_DSYNC = c.UV_FS_O_DSYNC;
    pub const FS_O_EXCL = c.UV_FS_O_EXCL;
    pub const FS_O_EXLOCK = c.UV_FS_O_EXLOCK;
    pub const FS_O_NOATIME = c.UV_FS_O_NOATIME;
    pub const FS_O_NOCTTY = c.UV_FS_O_NOCTTY;
    pub const FS_O_NOFOLLOW = c.UV_FS_O_NOFOLLOW;
    pub const FS_O_NONBLOCK = c.UV_FS_O_NONBLOCK;
    pub const FS_O_RDONLY = c.UV_FS_O_RDONLY;
    pub const FS_O_RDWR = c.UV_FS_O_RDWR;
    pub const FS_O_SYMLINK = c.UV_FS_O_SYMLINK;
    pub const FS_O_SYNC = c.UV_FS_O_SYNC;
    pub const FS_O_TRUNC = c.UV_FS_O_TRUNC;
    pub const FS_O_WRONLY = c.UV_FS_O_WRONLY;
};
