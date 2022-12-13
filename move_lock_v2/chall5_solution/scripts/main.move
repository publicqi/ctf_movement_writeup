script {
    use chall5::exp;
    use ctfmovement::move_lock;
    fun main(account: &signer){
        let p = exp::unlock();
        move_lock::unlock(account, p);
    }
}