module MyModule::EmergencyPause {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    

    struct SecurityPause has store, key {
        is_globally_paused: bool,     
        is_transfers_paused: bool,    
        admin: address,               
        pause_reason: u8,             
        pause_timestamp: u64,         
        total_operations: u64,       
    }
    
   
    const PAUSE_SECURITY: u8 = 1;
    const PAUSE_MAINTENANCE: u8 = 2;
    const PAUSE_UPGRADE: u8 = 3;
    
    
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_SYSTEM_PAUSED: u64 = 2;
    const E_TRANSFERS_PAUSED: u64 = 3;
    const E_SYSTEM_EXISTS: u64 = 4;
    const E_INVALID_REASON: u64 = 5;
    
    
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
    
  
    public fun emergency_pause(caller: &signer, system_owner: address, reason: u8, pause_transfers_only: bool) acquires SecurityPause {
        let caller_addr = signer::address_of(caller);
        let pause_system = borrow_global_mut<SecurityPause>(system_owner);
        
        
        assert!(caller_addr == pause_system.admin, E_NOT_AUTHORIZED);
        assert!(reason >= 1 && reason <= 3, E_INVALID_REASON);
        
        
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