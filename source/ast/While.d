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

    Expression test () {
	return this._test;
    }

    Block block () {
	return this._block;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<While:%d> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this.id,
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);

	this._test.print (nb + 4);
	this._block.print (nb + 4);
    }

    override void prettyPrint (int nb = 0) {
	writef ("%swhile (", rightJustify ("", nb, ' '));
	this._test.prettyPrint (0);
	writeln (") do ");
	this._block.prettyPrint (nb);	
    }


    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("%swhile (", rightJustify ("", nb, ' '));
	this._test.prettyPrint (buf, 0);
	buf.writeln (") do ");
	this._block.prettyPrint (buf, nb);	
    }

    
}
