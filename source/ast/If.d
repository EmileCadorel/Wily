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

    Expression test () {
	return this._test;
    }

    Else else_ () {
	return this._else;
    }
    
    Block block () {
	return this._block;
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

    override void prettyPrint (int nb = 0) {
	writef ("%sif (", rightJustify ("", nb, ' '));
	this._test.prettyPrint (0);
	writeln (")");
	this._block.prettyPrint (nb);
	if (this._else)
	    this._else.prettyPrint (nb);
    }

    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("%sif (", rightJustify ("", nb, ' '));
	this._test.prettyPrint (buf, 0);
	buf.writeln (")");
	this._block.prettyPrint (buf, nb);
	if (this._else)
	    this._else.prettyPrint (buf, nb);
    }

    
}

class Else : Instruction {
    private Block _block;
    
    this (Word token, Block block) {
	super (token);
	this._block = block;
    }   

    Block block () {
	return this._block;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Else> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	
	this._block.print (nb + 4);
    }    

    override void prettyPrint (int nb = 0) {
	writef ("%selse", rightJustify ("", nb, ' '));
	this._block.prettyPrint (nb);	
    }


    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("%selse", rightJustify ("", nb, ' '));
	this._block.prettyPrint (buf, nb);	   
    }
    
}
