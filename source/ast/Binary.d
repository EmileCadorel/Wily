module ast.Binary;
import ast.Expression;
import syntax.Word;
import std.stdio, std.string;

class Affect : Expression {

    private Expression _left;
    private Expression _right;
    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
    }

    override void print (int nb = 0) {
	writefln ("%s<Binary> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }
}

class Binary : Expression {

    private Expression _left;
    private Expression _right;

    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
    }    

    override void print (int nb = 0) {
	writefln ("%s<Binary> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }
}
