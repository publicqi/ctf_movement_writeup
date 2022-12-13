script {
    use ctfmovement::hello_move;

    fun main(account: &signer){
        hello_move::init_challenge(account);
    }
}