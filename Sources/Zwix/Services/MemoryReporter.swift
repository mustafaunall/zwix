import Darwin

enum MemoryReporter {
    /// Resident memory (RSS) of a process, in bytes. Returns 0 if the PID
    /// is invalid or already gone — safe to call right before terminating.
    static func residentMemory(pid: pid_t) -> UInt64 {
        var info = proc_taskinfo()
        let size = Int32(MemoryLayout<proc_taskinfo>.size)
        let result = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, size)
        guard result == size else { return 0 }
        return info.pti_resident_size
    }
}
