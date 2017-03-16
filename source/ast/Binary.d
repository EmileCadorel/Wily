module ast.Binary;
import ast.Expression;
import syntax.Word;
import std.stdio, std.string;
import std.outbuffer;

class Affect : Expression {

    private Expression _left;
    private Expression _right;
    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
    }

    override void print (int nb = 0) {
	writefln ("%s<Affect:%d> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this.id,
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	this._left.print (nb + 4);
	this._right.print (nb + 4);	
    }

    ref Expression left () {
	return this._left;
    }

    ref Expression right () {
	return this._right;
    }
    
    override void prettyPrint (int nb = 0) {
	writef ("%s", rightJustify ("", nb, ' '));
	this._left.prettyPrint (0);
	write (" := ");
	this._right.prettyPrint (0);
    }

    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("%s", rightJustify ("", nb, ' '));
	this._left.prettyPrint (buf, 0);
	buf.write (" := ");
	this._right.prettyPrint (buf, 0);
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
	writefln ("%s<Binary:%d> : %s(%d, %d) %s ", rightJustify ("", nb, ' '),
		  this.id,
		  this._token.locus.file,
		  this._token.locus.line, 
		  this._token.locus.column,
		  this._token.str);
	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }

    ref Expression left () {
	return this._left;
    }

    ref Expression right () {
	return this._right;
    }

    Word op () {
	return this._token;
    }
    
    override void prettyPrint (int nb = 0) {
	writef ("(%s", rightJustify ("", nb, ' '));
	this._left.prettyPrint (0);
	writef (" %s ", this._token.str);
	this._right.prettyPrint (0);
	write (")");
    }

    override void prettyPrint (OutBuffer buf, int nb = 0) {
	buf.writef ("(%s", rightJustify ("", nb, ' '));
	this._left.prettyPrint (buf, 0);
	buf.writef (" %s ", this._token.str);
	this._right.prettyPrint (buf, 0);
	buf.write (")");
    }

    
}
