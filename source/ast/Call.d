module ast.Call;
import ast.Instruction;
import syntax.Word;
import ast.Expression;
import std.container;
import std.stdio, std.string;

class Call : Instruction {

    private Array!Expression _params;
    
    this (Word token, Array!Expression params) {
	super (token);
	this._params = params;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Call:%d> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this.id,
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	foreach (it ; this._params)
	    it.print (nb + 4);
    }

    override void prettyPrint (int nb = 0) {
	writef ("call:%s(", this._token.str);
	foreach (it ; this._params) {
	    it.prettyPrint (0);
	    if (it !is this._params [$ - 1])
		write (",");
	}
	writef (")");
    }    

    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("call:%s(", this._token.str);
	foreach (it ; this._params) {
	    it.prettyPrint (buf, 0);
	    if (it !is this._params [$ - 1])
		buf.write (",");
	}
	buf.writef (")");
    }    

}

