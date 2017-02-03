module ast.Call;
import ast.Instruction;
import syntax.Word;
import ast.Expression;
import std.container;

class Call : Instruction {

    private Array!Expression _params;
    
    this (Word token, Array!Expression params) {
	super (token);
	this._params = params;
    }
    

}
