module ast.Constante;
import syntax.Word;
import ast.Expression;
import std.stdio, std.string;

class Var : Expression {

    this (Word token) {
	super (token);
    }

    override void print (int nb = 0) {
	writefln ("%s<Var> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
    }
}


class Int : Expression {
    this (Word token) {
	super (token);
    }

    override void print (int nb = 0) {
	writefln ("%s<Int> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
    }
}

class Bool : Expression {
    this (Word token) {
	super (token);
    }

    override void print (int nb = 0) {
	writefln ("%s<Bool> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
    }

}
