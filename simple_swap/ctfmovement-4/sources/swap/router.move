module ctfmovement::router {
    use ctfmovement::swap;
    use std::signer;
    use aptos_framework::coin;
    use ctfmovement::swap_utils;

    const E_OUTPUT_LESS_THAN_MIN: u64 = 0;
    const E_INSUFFICIENT_X_AMOUNT: u64 = 1;
    const E_INSUFFICIENT_Y_AMOUNT: u64 = 2;
    const E_PAIR_NOT_CREATED: u64 = 3;

    /// Create a Pair from 2 Coins
    /// Should revert if the pair is already created
    public entry fun create_pair<X, Y>(
        sender: &signer,
    ) {
        if (swap_utils::sort_token_type<X, Y>()) {
            swap::create_pair<X, Y>(sender);
        } else {
            swap::create_pair<Y, X>(sender);
        }
    }


    /// Add Liquidity, create pair if it's needed
    public entry fun add_liquidity<X, Y>(
        sender: &signer,
        amount_x_desired: u64,
        amount_y_desired: u64,
        amount_x_min: u64,
        amount_y_min: u64,
    ) {
        if (!(swap::is_pair_created<X, Y>() || swap::is_pair_created<Y, X>())) {
            create_pair<X, Y>(sender);
        };

        let amount_x;
        let amount_y;
        let _lp_amount;
        if (swap_utils::sort_token_type<X, Y>()) {
            (amount_x, amount_y, _lp_amount) = swap::add_liquidity<X, Y>(sender, amount_x_desired, amount_y_desired);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        } else {
            (amount_y, amount_x, _lp_amount) = swap::add_liquidity<Y, X>(sender, amount_y_desired, amount_x_desired);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        };
    }

    fun is_pair_created_internal<X, Y>(){
        assert!(swap::is_pair_created<X, Y>() || swap::is_pair_created<Y, X>(), E_PAIR_NOT_CREATED);
    }

    /// Remove Liquidity
    public entry fun remove_liquidity<X, Y>(
        sender: &signer,
        liquidity: u64,
        amount_x_min: u64,
        amount_y_min: u64
    ) {
        is_pair_created_internal<X, Y>();
        let amount_x;
        let amount_y;
        if (swap_utils::sort_token_type<X, Y>()) {
            (amount_x, amount_y) = swap::remove_liquidity<X, Y>(sender, liquidity);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        } else {
            (amount_y, amount_x) = swap::remove_liquidity<Y, X>(sender, liquidity);
            assert!(amount_x >= amount_x_min, E_INSUFFICIENT_X_AMOUNT);
            assert!(amount_y >= amount_y_min, E_INSUFFICIENT_Y_AMOUNT);
        }
    }

    /// Swap exact input amount of X to maxiumin possible amount of Y
    public entry fun swap<X, Y>(
        sender: &signer,
        x_in: u64,
        y_min_out: u64,
    ) {
        is_pair_created_internal<X, Y>();
        let y_out = if (swap_utils::sort_token_type<X, Y>()) {
            swap::swap_exact_x_to_y<X, Y>(sender, x_in, signer::address_of(sender))
        } else {
            swap::swap_exact_y_to_x<Y, X>(sender, x_in, signer::address_of(sender))
        };
        assert!(y_out >= y_min_out, E_OUTPUT_LESS_THAN_MIN);
    }

    public entry fun register_token<X>(sender: &signer) {
        coin::register<X>(sender);
    }
}
