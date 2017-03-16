module ast.Program;
import std.container, std.stdio, std.string;
import ast.Function;
import ast.Instruction;
import syntax.Word;

class Program {

    private Word _id;
    private Array!Function _decls;
    private Array!Instruction _vars;
    private Array!Instruction _begins;

    
    this (Word id, Array!Function decls, Array!Instruction vars, Array!Instruction begins) {
	this._id = id;
	this._decls = decls;
	this._vars = vars;
	this._begins = begins;

    }

    Word id () {
	return this._id;
    }

    Array!Function decls () {
	return this._decls;
    }

    Array!Instruction vars () {
	return this._vars;
    }

    Array!Instruction begins () {
	return this._begins;
    }
    
    
    void print (int nb = 0) {
	writefln ("%s<Program> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._id.locus.file,
		  this._id.locus.line, 
		  this._id.locus.column,
		  this._id.str);
	
	foreach (it ; this._decls)
	    it.print (nb + 4);

	foreach (it ; this._vars)
	    it.print (nb + 4);

	foreach (it ; _begins)
	    it.print (nb + 4);
    }


    void prettyPrint (int nb = 0) {
	foreach (it ; this._decls) {
	    it.prettyPrint (0);
	    writeln ();
	}
	
	foreach (it ; this._vars) {
	    it.prettyPrint (0);
	    writeln ();
	}

	writeln ("begin");
	foreach (it ; this._begins) {
	    it.prettyPrint (4);
	    writeln (";");
	}
	writeln ("end");
    }
    
    void prettyPrint (OutBuffer buf, int nb = 0) {
	foreach (it ; this._decls) {
	    it.prettyPrint (buf, 0);
	    buf.writeln ();
	}
	
	foreach (it ; this._vars) {
	    it.prettyPrint (buf, 0);
	    buf.writeln ();
	}

	buf.writeln ("begin");
	foreach (it ; this._begins) {
	    it.prettyPrint (buf, 4);
	    buf.writeln (";");
	}
	buf.writeln ("end");
    }
    


}
