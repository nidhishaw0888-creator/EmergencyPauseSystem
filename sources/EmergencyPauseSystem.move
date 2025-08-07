module MyModule::EmergencyPause {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    
    /// Struct representing comprehensive pause mechanisms for security
    struct SecurityPause has store, key {
        is_globally_paused: bool,     // Global system pause state
        is_transfers_paused: bool,    // Transfer-specific pause state
        admin: address,               // Emergency admin address
        pause_reason: u8,             // Reason code for pause (1=security, 2=maintenance, 3=upgrade)
        pause_timestamp: u64,         // Timestamp when pause was activated
        total_operations: u64,        // Total operations before pause
    }
    
    /// Pause reason codes
    const PAUSE_SECURITY: u8 = 1;
    const PAUSE_MAINTENANCE: u8 = 2;
    const PAUSE_UPGRADE: u8 = 3;
    
    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_SYSTEM_PAUSED: u64 = 2;
    const E_TRANSFERS_PAUSED: u64 = 3;
    const E_SYSTEM_EXISTS: u64 = 4;
    const E_INVALID_REASON: u64 = 5;
    
    /// Function to initialize comprehensive pause system
    public fun initialize_pause_system(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        assert!(!exists<SecurityPause>(admin_addr), E_SYSTEM_EXISTS);
        
        let pause_system = SecurityPause {
            is_globally_paused: false,
            is_transfers_paused: false,
            admin: admin_addr,
            pause_reason: 0,
            pause_timestamp: 0,
            total_operations: 0,
        };
        move_to(admin, pause_system);
    }
    
    /// Function to activate comprehensive emergency pause with reason
    public fun emergency_pause(caller: &signer, system_owner: address, reason: u8, pause_transfers_only: bool) acquires SecurityPause {
        let caller_addr = signer::address_of(caller);
        let pause_system = borrow_global_mut<SecurityPause>(system_owner);
        
        // Verify admin authorization
        assert!(caller_addr == pause_system.admin, E_NOT_AUTHORIZED);
        assert!(reason >= 1 && reason <= 3, E_INVALID_REASON);
        
        // Set pause parameters based on security level
        if (pause_transfers_only) {
            pause_system.is_transfers_paused = true;
        } else {
            pause_system.is_globally_paused = true;
            pause_system.is_transfers_paused = true;
        };
        
        pause_system.pause_reason = reason;
        pause_system.pause_timestamp = timestamp::now_seconds();
    }
}