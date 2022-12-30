const c = @import("c.zig").c;

/// A `libuv` error
pub const Error = error{
    /// Argument list too long
    UV_E2BIG,
    /// Permission denied
    UV_EACCES,
    /// Address already in use
    UV_EADDRINUSE,
    /// Address not available
    UV_EADDRNOTAVAIL,
    /// Address family not supported
    UV_EAFNOSUPPORT,
    /// Resource temporarily unavailable
    UV_EAGAIN,
    /// Address family not supported
    UV_EAI_ADDRFAMILY,
    /// Temporary failure
    UV_EAI_AGAIN,
    /// Bad `ai_flags` value
    UV_EAI_BADFLAGS,
    /// Invalid value for hints
    UV_EAI_BADHINTS,
    /// Request canceled
    UV_EAI_CANCELED,
    /// Permanent failure
    UV_EAI_FAIL,
    /// `ai_family` not supported
    UV_EAI_FAMILY,
    /// Out of memory
    UV_EAI_MEMORY,
    /// No address
    UV_EAI_NODATA,
    /// Unknown node or service
    UV_EAI_NONAME,
    /// Argument buffer overflow
    UV_EAI_OVERFLOW,
    /// Resolved protocol is unknown
    UV_EAI_PROTOCOL,
    /// Service not available for socket type
    UV_EAI_SERVICE,
    /// Socket type not supported
    UV_EAI_SOCKTYPE,
    /// Connection already in progress
    UV_EALREADY,
    /// Bad file descriptor
    UV_EBADF,
    /// Resource busy or locked
    UV_EBUSY,
    /// Operation canceled
    UV_ECANCELED,
    /// Invalid Unicode character
    UV_ECHARSET,
    /// Software caused connection abort
    UV_ECONNABORTED,
    /// Connection refused
    UV_ECONNREFUSED,
    /// Connection reset by peer
    UV_ECONNRESET,
    /// Destination address required
    UV_EDESTADDRREQ,
    /// File already exists
    UV_EEXIST,
    /// Bad address in system call argument
    UV_EFAULT,
    /// File too large
    UV_EFBIG,
    /// Host is unreachable
    UV_EHOSTUNREACH,
    /// Interrupted system call
    UV_EINTR,
    /// Invalid argument
    UV_EINVAL,
    /// I/O error
    UV_EIO,
    /// Socket is already connected
    UV_EISCONN,
    /// Illegal operation on a directory
    UV_EISDIR,
    /// Too many symbolic links encountered
    UV_ELOOP,
    /// Too many open files
    UV_EMFILE,
    /// Message too long
    UV_EMSGSIZE,
    /// Name too long
    UV_ENAMETOOLONG,
    /// Network is down
    UV_ENETDOWN,
    /// Network is unreachable
    UV_ENETUNREACH,
    /// File table overflow
    UV_ENFILE,
    /// No buffer space available
    UV_ENOBUFS,
    /// No such device
    UV_ENODEV,
    /// No such file or directory
    UV_ENOENT,
    /// Not enough memory
    UV_ENOMEM,
    /// Machine is not on the network
    UV_ENONET,
    /// Protocol not available
    UV_ENOPROTOOPT,
    /// No space left on device
    UV_ENOSPC,
    /// Function not implemented
    UV_ENOSYS,
    /// Socket is not connected
    UV_ENOTCONN,
    /// Not a directory
    UV_ENOTDIR,
    /// Directory not empty
    UV_ENOTEMPTY,
    /// Socket operation on non-socket
    UV_ENOTSOCK,
    /// Operation not supported on socket
    UV_ENOTSUP,
    /// Value too large for defined data type
    UV_EOVERFLOW,
    /// Operation not permitted
    UV_EPERM,
    /// Broken pipe
    UV_EPIPE,
    /// Protocol error
    UV_EPROTO,
    /// Protocol not supported
    UV_EPROTONOSUPPORT,
    /// Protocol wrong type for socket
    UV_EPROTOTYPE,
    /// Result too large
    UV_ERANGE,
    /// Read-only file system
    UV_EROFS,
    /// Cannot send after transport endpoint shutdown
    UV_ESHUTDOWN,
    /// Invalid seek
    UV_ESPIPE,
    /// No such process
    UV_ESRCH,
    /// Connection timed out
    UV_ETIMEDOUT,
    /// Text file is busy
    UV_ETXTBSY,
    /// Cross-device link not permitted
    UV_EXDEV,
    /// Unknown error
    UV_UNKNOWN,
    /// End of file
    UV_EOF,
    /// No such device or address
    UV_ENXIO,
    /// Too many links
    UV_EMLINK,
    /// Inappropriate ioctl for device
    UV_ENOTTY,
    /// Inappropriate file type or format
    UV_EFTYPE,
    /// Illegal byte sequence
    UV_EILSEQ,
    /// Socket type not supported
    UV_ESOCKTNOSUPPORT,
};

/// If there is an error, create an appropriate error variant
///
/// Unfortunately, Zig's error sets don't support negative
/// values, and the default tag is a hardcoded `u16`
pub fn check(res: c_int) Error!void {
    if (res >= 0) return;
    return switch (res) {
        c.UV_E2BIG => Error.UV_E2BIG,
        c.UV_EACCES => Error.UV_EACCES,
        c.UV_EADDRINUSE => Error.UV_EADDRINUSE,
        c.UV_EADDRNOTAVAIL => Error.UV_EADDRNOTAVAIL,
        c.UV_EAFNOSUPPORT => Error.UV_EAFNOSUPPORT,
        c.UV_EAGAIN => Error.UV_EAGAIN,
        c.UV_EAI_ADDRFAMILY => Error.UV_EAI_ADDRFAMILY,
        c.UV_EAI_AGAIN => Error.UV_EAI_AGAIN,
        c.UV_EAI_BADFLAGS => Error.UV_EAI_BADFLAGS,
        c.UV_EAI_BADHINTS => Error.UV_EAI_BADHINTS,
        c.UV_EAI_CANCELED => Error.UV_EAI_CANCELED,
        c.UV_EAI_FAIL => Error.UV_EAI_FAIL,
        c.UV_EAI_FAMILY => Error.UV_EAI_FAMILY,
        c.UV_EAI_MEMORY => Error.UV_EAI_MEMORY,
        c.UV_EAI_NODATA => Error.UV_EAI_NODATA,
        c.UV_EAI_NONAME => Error.UV_EAI_NONAME,
        c.UV_EAI_OVERFLOW => Error.UV_EAI_OVERFLOW,
        c.UV_EAI_PROTOCOL => Error.UV_EAI_PROTOCOL,
        c.UV_EAI_SERVICE => Error.UV_EAI_SERVICE,
        c.UV_EAI_SOCKTYPE => Error.UV_EAI_SOCKTYPE,
        c.UV_EALREADY => Error.UV_EALREADY,
        c.UV_EBADF => Error.UV_EBADF,
        c.UV_EBUSY => Error.UV_EBUSY,
        c.UV_ECANCELED => Error.UV_ECANCELED,
        c.UV_ECHARSET => Error.UV_ECHARSET,
        c.UV_ECONNABORTED => Error.UV_ECONNABORTED,
        c.UV_ECONNREFUSED => Error.UV_ECONNREFUSED,
        c.UV_ECONNRESET => Error.UV_ECONNRESET,
        c.UV_EDESTADDRREQ => Error.UV_EDESTADDRREQ,
        c.UV_EEXIST => Error.UV_EEXIST,
        c.UV_EFAULT => Error.UV_EFAULT,
        c.UV_EFBIG => Error.UV_EFBIG,
        c.UV_EHOSTUNREACH => Error.UV_EHOSTUNREACH,
        c.UV_EINTR => Error.UV_EINTR,
        c.UV_EINVAL => Error.UV_EINVAL,
        c.UV_EIO => Error.UV_EIO,
        c.UV_EISCONN => Error.UV_EISCONN,
        c.UV_EISDIR => Error.UV_EISDIR,
        c.UV_ELOOP => Error.UV_ELOOP,
        c.UV_EMFILE => Error.UV_EMFILE,
        c.UV_EMSGSIZE => Error.UV_EMSGSIZE,
        c.UV_ENAMETOOLONG => Error.UV_ENAMETOOLONG,
        c.UV_ENETDOWN => Error.UV_ENETDOWN,
        c.UV_ENETUNREACH => Error.UV_ENETUNREACH,
        c.UV_ENFILE => Error.UV_ENFILE,
        c.UV_ENOBUFS => Error.UV_ENOBUFS,
        c.UV_ENODEV => Error.UV_ENODEV,
        c.UV_ENOENT => Error.UV_ENOENT,
        c.UV_ENOMEM => Error.UV_ENOMEM,
        c.UV_ENONET => Error.UV_ENONET,
        c.UV_ENOPROTOOPT => Error.UV_ENOPROTOOPT,
        c.UV_ENOSPC => Error.UV_ENOSPC,
        c.UV_ENOSYS => Error.UV_ENOSYS,
        c.UV_ENOTCONN => Error.UV_ENOTCONN,
        c.UV_ENOTDIR => Error.UV_ENOTDIR,
        c.UV_ENOTEMPTY => Error.UV_ENOTEMPTY,
        c.UV_ENOTSOCK => Error.UV_ENOTSOCK,
        c.UV_ENOTSUP => Error.UV_ENOTSUP,
        c.UV_EOVERFLOW => Error.UV_EOVERFLOW,
        c.UV_EPERM => Error.UV_EPERM,
        c.UV_EPIPE => Error.UV_EPIPE,
        c.UV_EPROTO => Error.UV_EPROTO,
        c.UV_EPROTONOSUPPORT => Error.UV_EPROTONOSUPPORT,
        c.UV_EPROTOTYPE => Error.UV_EPROTOTYPE,
        c.UV_ERANGE => Error.UV_ERANGE,
        c.UV_EROFS => Error.UV_EROFS,
        c.UV_ESHUTDOWN => Error.UV_ESHUTDOWN,
        c.UV_ESPIPE => Error.UV_ESPIPE,
        c.UV_ESRCH => Error.UV_ESRCH,
        c.UV_ETIMEDOUT => Error.UV_ETIMEDOUT,
        c.UV_ETXTBSY => Error.UV_ETXTBSY,
        c.UV_EXDEV => Error.UV_EXDEV,
        c.UV_UNKNOWN => Error.UV_UNKNOWN,
        c.UV_EOF => Error.UV_EOF,
        c.UV_ENXIO => Error.UV_ENXIO,
        c.UV_EMLINK => Error.UV_EMLINK,
        c.UV_ENOTTY => Error.UV_ENOTTY,
        c.UV_EFTYPE => Error.UV_EFTYPE,
        c.UV_EILSEQ => Error.UV_EILSEQ,
        c.UV_ESOCKTNOSUPPORT => Error.UV_ESOCKTNOSUPPORT,
        else => unreachable,
    };
}
