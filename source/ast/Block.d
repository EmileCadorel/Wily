module ast.Block;
import ast.Instruction;
import std.container, syntax.Word;
import std.stdio, std.string;

class Block : Instruction {
    
    Array!Instruction _insts;
    
    this (Word token, Array!Instruction insts) {
	super (token);
	this._insts = insts;
    }

    override void print (int nb = 0) {
	writefln ("%s<Block> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	foreach (it ; this._insts)
	    it.print (nb + 4);
    }
    
}
