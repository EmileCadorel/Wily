module ast.While;
import ast.Instruction;
import ast.Expression, ast.Block;
import syntax.Word;

class While : Instruction {

    private Expression _test;
    private Block _block;

    this (Word token, Expression test, Block block) {
	super (token);
	this._test = test;
	this._block = block;
    }
      
}
