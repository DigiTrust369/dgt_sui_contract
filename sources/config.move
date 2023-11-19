module vault::config {
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    friend vault::vault;

    // =================== Error =================

    const EWrongAdmin: u64 = 0;
    const EWrongFreeze: u64 = 1;
    const EWrongPointsRate: u64 = 2;

    // =================== Struct =================

    struct AdminCap has key {
        id: UID,
    }

    /// Config
    struct Config has key {
        id: UID,
        // Associate the `Config` with its `AdminCap`
        admin: ID,
        // Fee account
        fee_account: address,
        // Fee points rate
        points_rate: u64,
        // Contract freeze state
        freeze: bool,
    }

    // =================== Function =================

    /// Initial admin contract
    fun init(ctx: &mut TxContext) {
        let admin = AdminCap {
            id: object::new(ctx),
        };

        let config = Config {
            id: object::new(ctx),
            admin: object::id(&admin),
            fee_account: tx_context::sender(ctx),
            points_rate: 500,
            freeze: false,
        };

        transfer::share_object(config);

        transfer::transfer(admin, tx_context::sender(ctx));
    }

    /// Get signer public key
    public(friend) fun get_fee_account(config: &Config): address {
        config.fee_account
    }

    /// Get points rate
    public(friend) fun get_points_rate(config: &Config): u64 {
        config.points_rate
    }

    public(friend) fun assert_admin(admin_cap: &AdminCap, config: &Config) {
        assert!(config.admin == object::id(admin_cap), EWrongAdmin);
    }

    /// Check contract not freeze
    public(friend) fun assert_not_freeze(config: &Config) {
        assert!(!config.freeze, EWrongFreeze);
    }

    /// Set admin address
    public entry fun set_contract_admin(
        admin_cap: AdminCap,
        config: &Config,
        new_owner: address,
        _ctx: &mut TxContext
    ) {
        assert_admin(&admin_cap, config);
        transfer::transfer(admin_cap, new_owner);
    }

    /// Set fee account
    public entry fun set_fee_account(
        admin_cap: &AdminCap,
        config: &mut Config,
        fee_account: address,
        _ctx: &mut TxContext
    ) {
        assert_admin(admin_cap, config);
        config.fee_account = fee_account;
    }

    /// Set points rate
    public entry fun set_points_rate(
        admin_cap: &AdminCap,
        config: &mut Config,
        points_rate: u64,
        _ctx: &mut TxContext
    ) {
        assert_admin(admin_cap, config);
        assert!(points_rate >= 0 && points_rate < 10000, EWrongPointsRate);
        config.points_rate = points_rate;
    }

    // /// Freezen contract / Unfreeze contract
    // public entry fun toggle_contract_freeze(
    //     admin_cap: &AdminCap,
    //     config: &mut Config,
    //     _ctx: &mut TxContext
    // ) {
    //     assert_admin(admin_cap, config);
    //     config.freeze = !config.freeze;
    // }
}
