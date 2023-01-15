const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const c = uv.c;
const check = uv.check;

/// Options for spawning a new thread
pub const ThreadOptions = extern struct {
    pub const UV = c.uv_thread_options_t;
    flags: enum(c_int) {
        NO_FLAGS = c.UV_THREAD_NO_FLAGS,
        HAS_STACK_SIZE = c.UV_THREAD_HAS_STACK_SIZE,
    },
    stack_size: usize,
};

/// Thread data
pub const Thread = extern struct {
    const Self = @This();
    pub const UV = c.uv_thread_t;
    pub const ThreadCallback = ?fn (?*anyopaque) callconv(.C) void;
    pub const ThreadCallbackUV = c.uv_thread_cb;
    self: c_ulong,
    usingnamespace Cast(Self);
    /// Create a thread
    pub fn create(
        self: *Self,
        entry: ThreadCallback,
        arg: ?*anyopaque,
    ) !void {
        const res = c.uv_thread_create(self.toUV(), entry, arg);
        try check(res);
    }
    /// Like `Self.create`, but additionally specifies
    /// options for creating a new thread
    pub fn createEx(
        self: *Self,
        params: *const ThreadOptions,
        entry: ThreadCallback,
        arg: ?*anyopaque,
    ) !void {
        const res = c.uv_thread_create_ex(
            self.toUV(),
            params,
            entry,
            arg,
        );
        try check(res);
    }
    /// Obtain ID of the calling thread
    pub fn current() Self {
        return Self.fromUV(c.uv_thread_self());
    }
    /// Join the thread
    pub fn join(self: *Self) !void {
        const res = c.uv_thread_join(self.toUV());
        try check(res);
    }
    /// Compare thread IDs
    pub fn equal(t1: *const Self, t2: *const Self) !c_int {
        const res = c.uv_thread_equal(t1, t2);
        try check(res);
        return res;
    }
};

/// Thread-local key
pub const Key = extern struct {
    const Self = @This();
    pub const UV = c.uv_key_t;
    self: c_uint,
    usingnamespace Cast();
    /// Create a key
    pub fn create(self: *Self) !void {
        const res = c.uv_key_create(self.toUV());
        try check(res);
    }
    /// Delete the key
    pub fn delete(self: *Self) void {
        c.uv_key_delete(self.toUV());
    }
    /// Get the value of the key
    pub fn get(self: *Self) ?*anyopaque {
        return c.uv_key_get(self.toUV());
    }
    /// Set the value of the key
    pub fn set(self: *Self, value: ?*anyopaque) void {
        return c.uv_key_set(self.toUV(), value);
    }
};

/// Once-only initializer
pub const Once = extern struct {
    const Self = @This();
    pub const UV = c.uv_once_t;
    self: c_int,
    usingnamespace Cast(Self);
    /// Run a function once and only once
    pub fn once(self: *Self, callback: ?fn () callconv(.C) void) void {
        c.uv_once(self.toUV(), callback);
    }
};

/// Mutex
pub const Mutex = extern union {
    const Self = @This();
    pub const UV = c.uv_mutex_t;
    __data: c.struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
    usingnamespace Cast(Self);
    /// Initialize a mutex
    pub fn init(self: *Self) !void {
        const res = c.uv_mutex_init(self.toUV());
        try check(res);
    }
    /// Initialize a recursive mutex
    pub fn initRecursive(self: *Self) !void {
        const res = c.uv_mutex_init_recursive(self.toUV());
        try check(res);
    }
    /// Destroy the mutex
    pub fn destroy(self: *Self) void {
        c.uv_mutex_destroy(self.toUV());
    }
    /// Lock the mutex
    pub fn lock(self: *Self) void {
        c.uv_mutex_lock(self.toUV());
    }
    /// Try to lock the mutex
    pub fn tryLock(self: *Self) !void {
        const res = c.uv_mutex_trylock(self.toUV());
        try check(res);
    }
    /// Unlock the mutex
    pub fn unlock(self: *Self) void {
        c.uv_mutex_unlock(self.toUV());
    }
};

/// Read-write lock
pub const RWLock = extern union {
    const Self = @This();
    pub const UV = c.uv_rwlock_t;
    __data: c.struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
    usingnamespace Cast(Self);
    /// Initialize a read-write lock
    pub fn init(self: *Self) !void {
        const res = c.uv_rwlock_init(self.toUV());
        try check(res);
    }
    /// Destroy the read-write lock
    pub fn destroy(self: *Self) void {
        c.uv_rwlock_destroy(self.toUV());
    }
    /// Lock the read-write lock for reading
    pub fn rdLock(self: *Self) void {
        c.uv_rwlock_rdlock(self.toUV());
    }
    /// Try to lock the read-write lock for reading
    pub fn tryRdLock(self: *Self) !void {
        const res = c.uv_rwlock_tryrdlock(self.toUV());
        try check(res);
    }
    /// Unlock the read-write lock from reading
    pub fn rdUnlock(self: *Self) void {
        c.uv_rwlock_rdunlock(self.toUV());
    }
    /// Lock the read-write lock for writing
    pub fn wrLock(self: *Self) void {
        c.uv_rwlock_wrlock(self.toUV());
    }
    /// Try to lock the read-write lock for writing
    pub fn tryWrLock(self: *Self) !void {
        const res = c.uv_rwlock_trywrlock(self.toUV());
        try check(res);
    }
    /// Unlock the read-write lock from writing
    pub fn wrUnlock(self: *Self) void {
        c.uv_rwlock_wrunlock(self.toUV());
    }
};

/// Semaphore
pub const Sem = extern union {
    const Self = @This();
    pub const UV = c.uv_sem_t;
    __size: [32]u8,
    __align: c_long,
    usingnamespace Cast(Self);
    /// Initialize a semaphore
    pub fn init(self: *Self, value: c_uint) !void {
        const res = c.uv_sem_init(self.toUV(), value);
        try check(res);
    }
    /// Destroy the semaphore
    pub fn destroy(self: *Self) void {
        c.uv_sem_destroy(self.toUV());
    }
    /// Try to lock a semaphore
    pub fn tryWait(self: *Self) void {
        const res = c.uv_sem_trywait(self.toUV());
        try check(res);
    }
};

/// Condition
pub const Cond = extern union {
    const Self = @This();
    pub const UV = c.uv_cond_t;
    __data: c.struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
    usingnamespace Cast(Self);
    /// Initialize a condition
    pub fn init(self: *Self) !void {
        const res = c.uv_cond_init(self.toUV());
        try check(res);
    }
    /// Destroy the condition
    pub fn destroy(self: *Self) void {
        c.uv_cond_destroy(self.toUV());
    }
    /// Unblock a single thread that is blocked on the condition
    pub fn signal(self: *Self) void {
        c.uv_cond_signal(self.toUV());
    }
    /// Unblock all threads that are blocked on the condition
    pub fn broadcast(self: *Self) void {
        c.uv_cond_broadcast(self.toUV());
    }
    /// Wait on the condition until the specific moment of time
    pub fn timedWait(self: *Self, mutex: *Mutex, timeout: u64) void {
        c.uv_cond_timedwait(self.toUV(), mutex.toUV(), timeout);
    }
};

/// Barrier
pub const Barrier = extern union {
    const Self = @This();
    pub const UV = c.uv_barrier_t;
    __size: [32]u8,
    __align: c_long,
    usingnamespace Cast(Self);
    /// Initialize a barrier
    pub fn init(self: *Self, count: c_uint) !void {
        const res = c.uv_barrier_init(self.toUV(), count);
        try check(res);
    }
    /// Destroy the barrier
    pub fn destroy(self: *Self) void {
        c.uv_barrier_destroy(self.toUV());
    }
    /// Wait on the barrier
    pub fn wait(self: *Self) !c_int {
        const res = c.uv_barrier_wait(self.toUV());
        try check(res);
        return res;
    }
};
