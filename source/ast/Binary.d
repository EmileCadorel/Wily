module ast.Binary;
import ast.Expression;
import syntax.Word;

class Affect : Expression {

    private Expression _left;
    private Expression _right;
    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
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

}
