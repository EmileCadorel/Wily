module ast.Instruction;
import syntax.Word;


class Instruction {
    
    protected Word _token;

    this (Word token) {
	this._token = token;
    }
    
    Word token () {
	return this._token;
    }       

    void print (int nb = 0) {}
}
