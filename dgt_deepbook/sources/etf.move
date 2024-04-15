module dacade_deepbook::etf {
    use sui::coin::{Coin, TreasuryCap, Self};
    use std::option;
    use sui::transfer;
    use sui::tx_context::{TxContext, Self};
    use sui::object::{Self, UID, ID};

    struct ETF has drop {}

    struct DepositEvent<phantom YT> has copy, drop {
        amount: u64,
        lp_minted: u64,
    }

    struct WithdrawEvent<phantom YT> has copy, drop {
        amount: u64,
        lp_burned: u64,
    }

    struct StrategyProfitEvent<phantom YT> has copy, drop {
        strategy_id: ID,
        profit: u64,
        fee_amt_yt: u64,
    }

    struct StrategyLossEvent<phantom YT> has copy, drop {
        strategy_id: ID,
        to_withdraw: u64,
        withdrawn: u64
    }

    /* ================= AdminCap ================= */

    /// There can only ever be one `AdminCap` for a `Vault`
    struct AdminCap<phantom YT> has key, store {
        id: UID,
    }

    #[allow(unused_function)]
    fun init(witness: ETF, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 6, b"ETF", b"", b"", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<ETF>, amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    public entry fun burn(treasury_cap: &mut TreasuryCap<ETF>, coin: Coin<ETF>) {
        coin::burn(treasury_cap, coin);
    }

    entry fun set_profit_unlock_duration_sec<T, YT>(
        _cap: &AdminCap<YT>, profit_unlock_duration_sec: u64
    ) {
        vault.profit_unlock_duration_sec = profit_unlock_duration_sec;
    }
}
