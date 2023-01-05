const std = @import("std");

const lib = @import("../lib.zig");

const Cast = lib.Cast;
const c = lib.c;

/// Socket length
const SockLen = c.socklen_t;

/// Address family
pub const AddrFamily = enum(c_int) {
    AF_INET = c.AF_INET,
    AF_INET6 = c.AF_INET6,
    AF_UNSPEC = c.AF_UNSPEC,
};

/// Socket type
pub const SockType = enum(c_int) {
    SOCK_CLOEXEC = c.SOCK_CLOEXEC,
    SOCK_DCCP = c.SOCK_DCCP,
    SOCK_DGRAM = c.SOCK_DGRAM,
    SOCK_NONBLOCK = c.SOCK_NONBLOCK,
    SOCK_PACKET = c.SOCK_PACKET,
    SOCK_RAW = c.SOCK_RAW,
    SOCK_RDM = c.SOCK_RDM,
    SOCK_SEQPACKET = c.SOCK_SEQPACKET,
    SOCK_STREAM = c.SOCK_STREAM,
};

/// IP protocol
pub const IPProtocol = enum(c_int) {
    IPPROTO_AH = c.IPPROTO_AH,
    IPPROTO_BEETPH = c.IPPROTO_BEETPH,
    IPPROTO_COMP = c.IPPROTO_COMP,
    IPPROTO_DCCP = c.IPPROTO_DCCP,
    IPPROTO_DSTOPTS = c.IPPROTO_DSTOPTS,
    IPPROTO_EGP = c.IPPROTO_EGP,
    IPPROTO_ENCAP = c.IPPROTO_ENCAP,
    IPPROTO_ESP = c.IPPROTO_ESP,
    IPPROTO_ETHERNET = c.IPPROTO_ETHERNET,
    IPPROTO_FRAGMENT = c.IPPROTO_FRAGMENT,
    IPPROTO_GRE = c.IPPROTO_GRE,
    IPPROTO_ICMP = c.IPPROTO_ICMP,
    IPPROTO_ICMPV6 = c.IPPROTO_ICMPV6,
    IPPROTO_IDP = c.IPPROTO_IDP,
    IPPROTO_IGMP = c.IPPROTO_IGMP,
    IPPROTO_IP_OR_HOPOPTS = c.IPPROTO_IP,
    IPPROTO_IPIP = c.IPPROTO_IPIP,
    IPPROTO_IPV6 = c.IPPROTO_IPV6,
    IPPROTO_MAX = c.IPPROTO_MAX,
    IPPROTO_MH = c.IPPROTO_MH,
    IPPROTO_MPLS = c.IPPROTO_MPLS,
    IPPROTO_MPTCP = c.IPPROTO_MPTCP,
    IPPROTO_MTP = c.IPPROTO_MTP,
    IPPROTO_NONE = c.IPPROTO_NONE,
    IPPROTO_PIM = c.IPPROTO_PIM,
    IPPROTO_PUP = c.IPPROTO_PUP,
    IPPROTO_RAW = c.IPPROTO_RAW,
    IPPROTO_ROUTING = c.IPPROTO_ROUTING,
    IPPROTO_RSVP = c.IPPROTO_RSVP,
    IPPROTO_SCTP = c.IPPROTO_SCTP,
    IPPROTO_TCP = c.IPPROTO_TCP,
    IPPROTO_TP = c.IPPROTO_TP,
    IPPROTO_UDP = c.IPPROTO_UDP,
    IPPROTO_UDPLITE = c.IPPROTO_UDPLITE,
};

/// IP port
pub const IPPort = enum(c_int) {
    IPPORT_CMDSERVER = c.IPPORT_CMDSERVER,
    IPPORT_DAYTIME = c.IPPORT_DAYTIME,
    IPPORT_DISCARD = c.IPPORT_DISCARD,
    IPPORT_ECHO = c.IPPORT_ECHO,
    IPPORT_EXECSERVER_OR_BIFFUDP = c.IPPORT_EXECSERVER,
    IPPORT_FINGER = c.IPPORT_FINGER,
    IPPORT_FTP = c.IPPORT_FTP,
    IPPORT_MTP = c.IPPORT_MTP,
    IPPORT_NAMESERVER = c.IPPORT_NAMESERVER,
    IPPORT_NETSTAT = c.IPPORT_NETSTAT,
    IPPORT_RESERVED = c.IPPORT_RESERVED,
    IPPORT_RJE = c.IPPORT_RJE,
    IPPORT_ROUTESERVER_OR_EFSSERVER = c.IPPORT_ROUTESERVER,
    IPPORT_SMTP = c.IPPORT_SMTP,
    IPPORT_SUPDUP = c.IPPORT_SUPDUP,
    IPPORT_SYSTAT = c.IPPORT_SYSTAT,
    IPPORT_TELNET = c.IPPORT_TELNET,
    IPPORT_TFTP = c.IPPORT_TFTP,
    IPPORT_TIMESERVER = c.IPPORT_TIMESERVER,
    IPPORT_TTYLINK = c.IPPORT_TTYLINK,
    IPPORT_USERRESERVED = c.IPPORT_USERRESERVED,
    IPPORT_WHOIS = c.IPPORT_WHOIS,
    IPPORT_WHOSERVER_OR_LOGINSERVER = c.IPPORT_WHOSERVER,
};

/// `addrinfo` struct
pub const AddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.struct_addrinfo;
    ai_flags: c_int,
    ai_family: AddrFamily,
    ai_socktype: SockType,
    ai_protocol: IPProtocol,
    ai_addrlen: SockLen,
    ai_addr: *SockAddr,
    ai_canonname: *u8,
    ai_next: *Self,
    usingnamespace Cast(Self);
    /// Free the struct
    pub fn free(self: *Self) void {
        c.uv_freeaddrinfo(self.toUV());
    }
};

/// `sockaddr` struct
pub const SockAddr = extern struct {
    const Self = @This();
    pub const UV = c.struct_sockaddr;
    sa_family: c.sa_family_t,
    sa_data: [14]u8,
    usingnamespace Cast(Self);
    /// Cast `*Self` to `*const SockAddrIn`
    pub fn asIn(self: *Self) *const SockAddrIn {
        return @ptrCast(*const SockAddrIn, @alignCast(@alignOf(SockAddrIn), self));
    }
};

/// `sockaddr_in` struct
pub const SockAddrIn = extern struct {
    const Self = @This();
    pub const UV = c.struct_sockaddr_in;
    sin_family: c.sa_family_t,
    sin_port: c.in_port_t,
    sin_addr: c.struct_in_addr,
    sin_zero: [8]u8,
    usingnamespace Cast(Self);
    /// Cast `*Self` to `*const SockAddr`
    pub fn asAddr(self: *Self) *const SockAddr {
        return @ptrCast(*const SockAddr, self);
    }
};
