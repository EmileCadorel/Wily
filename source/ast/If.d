module ast.If;
import ast.Instruction;
import syntax.Word, ast.Block;
import ast.Expression;

class If : Instruction {

    private Expression _test;
    private Block _block;
    private Else _else;
    
    this (Word token, Expression test, Block block, Else _else = null) {
	super (token);
	this._test = test;
	this._block = block;
	this._else = _else;
    }   
}

class Else : Instruction {
    private Block _block;
    
    this (Word token, Block block) {
	super (token);
	this._block = block;
    }   
}
