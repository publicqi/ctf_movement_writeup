module chall2::exp {
    use ctfmovement::hello_move;
    public entry fun init_chall(account: &signer){
        hello_move::init_challenge(account);
    }
}