module ast.Expression;
import ast.Instruction;
import syntax.Word;
import tables.Symbol;

class Expression : Instruction {
    this (Word token) {
	super (token);
    }    

    public ref Symbol symbol () {
	return _symbol;
    }

    override void print (int nb = 0) {}

    override void prettyPrint (int nb = 0) {}

    override void prettyPrint (OutBuffer buf, int nb = 0) {}
    
    private Symbol _symbol;
}
