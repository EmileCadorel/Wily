module ast.If;
import ast.Instruction;
import syntax.Word, ast.Block;
import ast.Expression;
import std.stdio, std.string;

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

    override void print (int nb = 0) {
	writefln ("%s<If> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	
	this._block.print (nb + 4);
	if (this._else)
	    this._else.print (nb + 4);
    }    
}

class Else : Instruction {
    private Block _block;
    
    this (Word token, Block block) {
	super (token);
	this._block = block;
    }   

    override void print (int nb = 0) {
	writefln ("%s<Else> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	
	this._block.print (nb + 4);
    }    

}
