const std = @import("std");

const uv = @import("../lib.zig");

const Cast = uv.Cast;
const c = uv.c;

/// Socket length
const SockLen = c.socklen_t;

/// Address family
pub usingnamespace struct {
    pub const AF_INET = c.AF_INET;
    pub const AF_INET6 = c.AF_INET6;
    pub const AF_UNSPEC = c.AF_UNSPEC;
};

/// Socket type
pub usingnamespace struct {
    pub const SOCK_CLOEXEC = c.SOCK_CLOEXEC;
    pub const SOCK_DCCP = c.SOCK_DCCP;
    pub const SOCK_DGRAM = c.SOCK_DGRAM;
    pub const SOCK_NONBLOCK = c.SOCK_NONBLOCK;
    pub const SOCK_PACKET = c.SOCK_PACKET;
    pub const SOCK_RAW = c.SOCK_RAW;
    pub const SOCK_RDM = c.SOCK_RDM;
    pub const SOCK_SEQPACKET = c.SOCK_SEQPACKET;
    pub const SOCK_STREAM = c.SOCK_STREAM;
};

/// IP protocol
pub usingnamespace struct {
    pub const IPPROTO_AH = c.IPPROTO_AH;
    pub const IPPROTO_BEETPH = c.IPPROTO_BEETPH;
    pub const IPPROTO_COMP = c.IPPROTO_COMP;
    pub const IPPROTO_DCCP = c.IPPROTO_DCCP;
    pub const IPPROTO_DSTOPTS = c.IPPROTO_DSTOPTS;
    pub const IPPROTO_EGP = c.IPPROTO_EGP;
    pub const IPPROTO_ENCAP = c.IPPROTO_ENCAP;
    pub const IPPROTO_ESP = c.IPPROTO_ESP;
    pub const IPPROTO_ETHERNET = c.IPPROTO_ETHERNET;
    pub const IPPROTO_FRAGMENT = c.IPPROTO_FRAGMENT;
    pub const IPPROTO_GRE = c.IPPROTO_GRE;
    pub const IPPROTO_HOPOPTS = c.IPPROTO_HOPOPTS;
    pub const IPPROTO_ICMP = c.IPPROTO_ICMP;
    pub const IPPROTO_ICMPV6 = c.IPPROTO_ICMPV6;
    pub const IPPROTO_IDP = c.IPPROTO_IDP;
    pub const IPPROTO_IGMP = c.IPPROTO_IGMP;
    pub const IPPROTO_IP = c.IPPROTO_IP;
    pub const IPPROTO_IPIP = c.IPPROTO_IPIP;
    pub const IPPROTO_IPV6 = c.IPPROTO_IPV6;
    pub const IPPROTO_MAX = c.IPPROTO_MAX;
    pub const IPPROTO_MH = c.IPPROTO_MH;
    pub const IPPROTO_MPLS = c.IPPROTO_MPLS;
    pub const IPPROTO_MPTCP = c.IPPROTO_MPTCP;
    pub const IPPROTO_MTP = c.IPPROTO_MTP;
    pub const IPPROTO_NONE = c.IPPROTO_NONE;
    pub const IPPROTO_PIM = c.IPPROTO_PIM;
    pub const IPPROTO_PUP = c.IPPROTO_PUP;
    pub const IPPROTO_RAW = c.IPPROTO_RAW;
    pub const IPPROTO_ROUTING = c.IPPROTO_ROUTING;
    pub const IPPROTO_RSVP = c.IPPROTO_RSVP;
    pub const IPPROTO_SCTP = c.IPPROTO_SCTP;
    pub const IPPROTO_TCP = c.IPPROTO_TCP;
    pub const IPPROTO_TP = c.IPPROTO_TP;
    pub const IPPROTO_UDP = c.IPPROTO_UDP;
    pub const IPPROTO_UDPLITE = c.IPPROTO_UDPLITE;
};

/// IP port
pub usingnamespace struct {
    pub const IPPORT_BIFFUDP = c.IPPORT_BIFFUDP;
    pub const IPPORT_CMDSERVER = c.IPPORT_CMDSERVER;
    pub const IPPORT_DAYTIME = c.IPPORT_DAYTIME;
    pub const IPPORT_DISCARD = c.IPPORT_DISCARD;
    pub const IPPORT_ECHO = c.IPPORT_ECHO;
    pub const IPPORT_EFSSERVER = c.IPPORT_EFSSERVER;
    pub const IPPORT_EXECSERVER = c.IPPORT_EXECSERVER;
    pub const IPPORT_FINGER = c.IPPORT_FINGER;
    pub const IPPORT_FTP = c.IPPORT_FTP;
    pub const IPPORT_LOGINSERVER = c.IPPORT_LOGINSERVER;
    pub const IPPORT_MTP = c.IPPORT_MTP;
    pub const IPPORT_NAMESERVER = c.IPPORT_NAMESERVER;
    pub const IPPORT_NETSTAT = c.IPPORT_NETSTAT;
    pub const IPPORT_RESERVED = c.IPPORT_RESERVED;
    pub const IPPORT_RJE = c.IPPORT_RJE;
    pub const IPPORT_ROUTESERVER = c.IPPORT_ROUTESERVER;
    pub const IPPORT_SMTP = c.IPPORT_SMTP;
    pub const IPPORT_SUPDUP = c.IPPORT_SUPDUP;
    pub const IPPORT_SYSTAT = c.IPPORT_SYSTAT;
    pub const IPPORT_TELNET = c.IPPORT_TELNET;
    pub const IPPORT_TFTP = c.IPPORT_TFTP;
    pub const IPPORT_TIMESERVER = c.IPPORT_TIMESERVER;
    pub const IPPORT_TTYLINK = c.IPPORT_TTYLINK;
    pub const IPPORT_USERRESERVED = c.IPPORT_USERRESERVED;
    pub const IPPORT_WHOIS = c.IPPORT_WHOIS;
    pub const IPPORT_WHOSERVER = c.IPPORT_WHOSERVER;
};

/// `addrinfo` struct
pub const AddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.struct_addrinfo;
    ai_flags: c_int,
    ai_family: c_int,
    ai_socktype: c_int,
    ai_protocol: c_int,
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
