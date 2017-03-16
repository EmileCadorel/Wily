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

    ref Array!Instruction insts () {
	return this._insts;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Block:%d> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this.id,
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	foreach (it ; this._insts)
	    it.print (nb + 4);
    }
    
    override void prettyPrint (int nb = 0) {
	writefln ("%s(", rightJustify ("", nb, ' '));
	foreach (it ; this._insts) {
	    it.prettyPrint (nb + 4);
	    writefln (";");
	}
	writefln ("%s)", rightJustify ("", nb, ' '));	
    }

    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writefln ("%s(", rightJustify ("", nb, ' '));
	foreach (it ; this._insts) {
	    it.prettyPrint (buf, nb + 4);
	    buf.writefln (";");
	}
	buf.writefln ("%s)", rightJustify ("", nb, ' '));	
    }

    
}
