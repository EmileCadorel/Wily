module ast.While;
import ast.Instruction;
import ast.Expression, ast.Block;
import syntax.Word;
import std.stdio, std.string;

class While : Instruction {

    private Expression _test;
    private Block _block;

    this (Word token, Expression test, Block block) {
	super (token);
	this._test = test;
	this._block = block;
    }

    override void print (int nb = 0) {
	writefln ("%s<While> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);

	this._test.print (nb + 4);
	this._block.print (nb + 4);
    }              
}
