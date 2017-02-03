module ast.Constante;
import syntax.Word;
import ast.Expression;

class Var : Expression {

    this (Word token) {
	super (token);
    }

}


class Int : Expression {
    this (Word token) {
	super (token);
    }
}

class Bool : Expression {
    this (Word token) {
	super (token);
    }
}
