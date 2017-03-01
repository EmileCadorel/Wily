module ast.Instruction;
import syntax.Word;


class Instruction {
    
    protected Word _token;
    private ulong _id;
    private static ulong __lastId__ = 0UL;
    
    this (Word token) {
	this._token = token;
	this._id = __lastId__;
	__lastId__ ++;
    }
    
    Word token () {
	return this._token;
    }       

    ulong id () {
	return this._id;
    }
    
    void print (int nb = 0) {}
}
