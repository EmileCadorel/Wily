module ast.VarDecl;
import std.container;
import ast.Instruction;
import syntax.Word;
import std.stdio, std.string;
import tables.Symbol;

class VarDecl : Instruction {

    private Array!Word _names;
    private Array!Symbol _symbols;
    
    this (Word type, Array!Word names) {
	super (type);
	this._names = names;
    }

    this (Word type, Array!Word names, Array!Symbol symbols) {
	super (type);
	this._names = names;
	this._symbols = symbols;
    }
    
    ref Word type () {
	return this._token;
    }

    ref Array!Word names () {
	return this._names;
    }

    ref Array!Symbol symbols () {
	return this._symbols;
    }
    
    override void print (int nb = 0) {
	writef ("%s<VarDecl> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);

	foreach (it ; this._names)
	    writef ("%s ", it.str ());
	writeln ();
    }        

    override void prettyPrint (int nb = 0) {
	writef ("%s%s ", rightJustify ("", nb, ' '), this._token.str);
	foreach (it ; this._names) {
	    write (it.str);
	    if (it !is this._names [$ - 1])
		write (", ");	    
	}
	write (";");
    }

    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("%s%s ", rightJustify ("", nb, ' '), this._token.str);
	foreach (it ; this._names) {
	    buf.write (it.str);
	    if (it !is this._names [$ - 1])
		buf.write (", ");	    
	}
	buf.write (";");
    }


    
}

