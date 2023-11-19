module vault::vault {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event::emit;
    use sui::object::{Self, ID, UID, uid_to_inner};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use vault::config::{get_fee_account, get_points_rate, AdminCap, Config, assert_admin, assert_not_freeze};

    // =================== Error =================

    const EWrongAmount: u64 = 0;
    const EWrongBalance: u64 = 1;

    // =================== Struct =================

    /// Case
    struct Case has key {
        id: UID,
        // Case id
        case_id: u64,
        // beneficiary
        beneficiary: address,
        // Balance
        balance: Balance<SUI>,
    }

    /// Case count
    struct CaseCount has key {
        id: UID,
        // Case count
        count: u64,
    }

    // ===================   Event  =================

    struct AddCaseEvent has copy, drop {
        id: ID,
        case_id: u64,
        beneficiary: address,
    }

    struct DepositEvent has copy, drop {
        case_id: u64,
        depositor: address,
        amount: u64,
    }

    struct PayEvent has copy, drop {
        case_id: u64,
        sender: address,
        beneficiary: address,
        amount: u64,
    }

    // =================== Function =================

    /// Initial
    fun init(ctx: &mut TxContext) {
        transfer::share_object(CaseCount {
            id: object::new(ctx),
            count: 0,
        });
    }

    /// Publish capital
    public entry fun publish_capital(
        admin_cap: &AdminCap,
        config: &Config,
        case_count: &mut CaseCount,
        beneficiary: address,
        ctx: &mut TxContext
    ) {
        assert_admin(admin_cap, config);
        let count = case_count.count;
        let case_id = count + 1;
        let uid = object::new(ctx);

        case_count.count = case_id;

        emit(AddCaseEvent {
            id: uid_to_inner(&uid),
            case_id,
            beneficiary,
        });

        transfer::share_object(Case {
            id: uid,
            case_id,
            beneficiary,
            balance: balance::zero(),
        });
    }

    /// Deposit
    public entry fun deposit(
        case: &mut Case,
        amount: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(coin::value(&amount) > 0, EWrongAmount);

        emit(DepositEvent {
            case_id: case.case_id,
            depositor: tx_context::sender(ctx),
            amount: coin::value(&amount),
        });

        balance::join(&mut case.balance, coin::into_balance(amount));
    }

    /// Pay to beneficiary
    public entry fun pay_to_beneficiary(
        case: &mut Case,
        config: &Config,
        amount: u64,
        ctx: &mut TxContext
    ) {
        // assert_not_freeze(config);
        assert!(amount > 0, EWrongAmount);
        assert!(balance::value(&case.balance) >= amount, EWrongBalance);

        let fee = 0;
        let points_rate = get_points_rate(config);
        if (points_rate > 0) {
            fee = amount * points_rate / 10000;
        };
        if (fee > 0) {
            let fee_coin = coin::take(&mut case.balance, fee, ctx);
            transfer::public_transfer(fee_coin, get_fee_account(config));
        };

        let coin = coin::take(&mut case.balance, amount - fee, ctx);
        transfer::public_transfer(coin, case.beneficiary);

        emit(PayEvent {
            case_id: case.case_id,
            sender: tx_context::sender(ctx),
            beneficiary: case.beneficiary,
            amount,
        });
    }
}
