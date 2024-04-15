// SPDX-License-Identifier: Apache-2.0
module vault::digitrust {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector;
    use sui::object::{Self, UID, ID};
    use std::string::{String};

    const INVALID_INDEX: u64 = 999999999;
    const ERROR_UNAUTHORIZED: u64 = 1;
    const ERROR_NOT_INITIALIZED: u64 = 2;
    const ERROR_USER_EXISTS: u64 = 3;
    const ERROR_USER_DOES_NOT_EXIST: u64 = 4;

    /// Name of the coin. By convention, this type has the same name as its parent module
    /// and has no fields. The full type of the coin defined by this module will be `COIN<DIGITRUST>`.
    struct DIGITRUST has drop {}

    /* ================= Vault ================= */

    struct Vault has key {
        id: UID,
        /// balance that's not allocated to any strategy
        free_balance: u64,
        /// slowly distribute profits over time to avoid sandwitch attacks on rebalance
        time_locked_profit: u64,
        /// treasury of the vault's yield-bearing token
        lp_treasury: address,
        /// strategies
        strategies: String,
        /// performance fee balance
        performance_fee_balance: u64,
        /// priority order for withdrawing from strategies
        strategy_withdraw_priority_order: vector<ID>,
        /// deposits are disabled above this threshold
        tvl_cap: u64,
        /// duration of profit unlock in seconds
        profit_unlock_duration_sec: u64,
        /// performance fee in basis points (taken from all profits)
        performance_fee_bps: u64,
        version: u64,
    } 

    /* ================= Portfolio ================= */
    struct Portfolio has key {
        id: UID,
        profit: u64,
        time_locked_profit: u64,
        performance_fee: u64,
        version: u64,
        chain_allocation: String
    }

    struct Signal has key {
        id: UID,
        users: vector<User>,
    }

    struct User has store, drop, copy {
        addr: address,
        name: String,
        bio: String,
        pfp: String,
        posts: vector<Post>,
        portfolios: vector<Portfolio>
    }

    struct Portfolio has store, drop, copy{
        symbol: String, 
        chain: String, 
        entry: String, 
        take_profit: String,
        cut_loss: String, 
        expire_time: u64,
    }

    struct Post has store, drop, copy {
        content: String,
        image: String,
        comments: vector<Comment>,
        like_count: u64,
        time: u64,
    }

    struct Comment has store, drop, copy {
        addr: address,
        content: String,
        like_count: u64,
        time: u64,
    }

    public entry fun generate_vault_strategy(
        strategy: String, recipient: address, ctx: &mut TxContext 
    ){
        let vault = Vault{
            id: object::new(ctx),

            free_balance: 0,
            time_locked_profit: 24,
            lp_treasury: recipient, 
            strategies: strategy,
            performance_fee_balance: 0,
            strategy_withdraw_priority_order: vector::empty(),

            tvl_cap: 20242411,
            profit_unlock_duration_sec: 24,
            performance_fee_bps: 0,

            version: 24,
        };
        transfer::share_object(vault);
    }

    /// Register the digitrust currency to acquire its `TreasuryCap`. Because
    /// this is a module initializer, it ensures the currency only gets
    /// registered once.
    fun init(witness: DIGITRUST, ctx: &mut TxContext) {
        // Get a treasury cap for the coin and give it to the transaction sender
        let (treasury_cap, metadata) = coin::create_currency<DIGITRUST>(witness, 2, b"DIGITRUST", b"", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx))
    }

    /// Manager can mint new coins
    public entry fun mint(
        treasury_cap: &mut TreasuryCap<DIGITRUST>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    /// Manager can burn coins
    public entry fun burn(treasury_cap: &mut TreasuryCap<DIGITRUST>, coin: Coin<DIGITRUST>) {
        coin::burn(treasury_cap, coin);

        //making connection as the core_relation between 
    }

    /** User profile **/
    public entry fun create_user_profile(account: &signer, name: String, bio: String, pfp: String) acquires Signal {
        assert!(exists<Signal>(MODULE_ADDRESS), ERROR_NOT_INITIALIZED);

        let signer_addr = signer::address_of(account);

        let dgt_signal = borrow_global_mut<Signal>(MODULE_ADDRESS);

        let n = 0;

        let users_count = vector::length(&dgt_signal.users);

        while(n < users_count) {
            let addr_of_nth_user = vector::borrow(&mut dgt_signal.users, n).addr;
            assert!(addr_of_nth_user != signer_addr, ERROR_USER_EXISTS);
            n = n + 1;
        };

        let new_user = User {
            addr: signer_addr,
            name: name,
            bio: bio,
            pfp: pfp,
            posts: vector[],
            portfolios: vector[]
        };

        vector::push_back(&mut dgt_signal.users, new_user);
    }

    public entry fun update_user_profile(account: &signer, name: String, bio: String, pfp: String) acquires Signal {
        assert!(exists<Signal>(MODULE_ADDRESS), ERROR_NOT_INITIALIZED);

        let signer_addr = signer::address_of(account);

        let dgt_signal = borrow_global_mut<Signal>(MODULE_ADDRESS);

        let n = 0;

        let users_count = vector::length(&dgt_signal.users);

        while(n < users_count) {
            let nth_user = vector::borrow_mut(&mut dgt_signal.users, n);

            if(nth_user.addr == signer_addr) {
                nth_user.name = name;
                nth_user.bio = bio;
                nth_user.pfp = pfp;
                return
            };

            n = n + 1;
        };

        abort ERROR_USER_DOES_NOT_EXIST
    }

    public entry fun make_post(account: &signer, content: String, image: String) acquires Signal {
        assert!(exists<Signal>(MODULE_ADDRESS), ERROR_NOT_INITIALIZED);

        let signer_addr = signer::address_of(account);

        let dgt_signal = borrow_global_mut<Signal>(MODULE_ADDRESS);

        let n = 0;

        let users_count = vector::length(&dgt_signal.users);

        while(n < users_count) {
            let nth_user = vector::borrow_mut(&mut dgt_signal.users, n);

            if(nth_user.addr == signer_addr) {
                let post = Post {
                    content: content,
                    image: image,
                    comments: vector[],
                    like_count: 0,
                    time: timestamp::now_seconds(),
                };

                vector::push_back(&mut nth_user.posts, post);

                return
            };

            n = n + 1;
        };

        abort ERROR_USER_DOES_NOT_EXIST
    }

    public entry fun share_portfolio(account: &signer, symbol: String, chain: String, entry: String, take_profit: String, cut_loss: String) acquires Signal {
        assert!(exists<Signal>(MODULE_ADDRESS), ERROR_NOT_INITIALIZED);

        let signer_addr = signer::address_of(account);

        let dgt_signal = borrow_global_mut<Signal>(MODULE_ADDRESS);

        let n = 0;

        let portfolio_count = vector::length(&dgt_signal.users);

        while(n < portfolio_count) {
            let nth_user = vector::borrow_mut(&mut dgt_signal.users, n);

            if(nth_user.addr == signer_addr) {
                let portfolio = Portfolio {
                    symbol: symbol,
                    chain: chain,
                    entry: entry,
                    take_profit: take_profit,
                    cut_loss: cut_loss,
                    expire_time: 24
                };

                vector::push_back(&mut nth_user.portfolios, portfolio);

                return
            };

            n = n + 1;
        };

        abort ERROR_USER_DOES_NOT_EXIST
    }

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(DIGITRUST {}, ctx)
    }
}
