module ast.Expression;
import ast.Instruction;
import syntax.Word;

class Expression : Instruction {
    this (Word token) {
	super (token);
    }    

   
    override void print (int nb = 0) {}
}
