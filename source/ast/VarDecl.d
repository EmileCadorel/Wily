module ast.VarDecl;
import std.container;
import ast.Instruction;
import syntax.Word;
import std.stdio, std.string;

class VarDecl : Instruction {

    private Array!Word _names;
   
    this (Word type, Array!Word names) {
	super (type);
	this._names = names;
    }

    override void print (int nb = 0) {
	writefln ("%s<VarDecl> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);

	foreach (it ; this._names)
	    writef ("%s ", it.str ());
    }        
}
