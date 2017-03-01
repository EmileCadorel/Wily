module analyse.disponible.Visitor;

import parent = analyse.parent.Visitor;
import std.stdio;
import ast.all;

class Visitor : parent.Visitor {

    override protected Function visit (Function _fun) {
	writeln ("Visiting Function");
	return _fun;
    }

    override protected Instruction visitVarDecl (VarDecl _decl) {
	writeln ("Visiting VarDecl");
	return _decl;
    }
    
    override protected Instruction visitIf (If _if) {
	writeln ("Visiting If");
	return _if;
    }

    override protected Instruction visitWhile (While _while) {
	writeln ("Visiting While");
	return _while;
    }

    override protected Instruction visitCall (Call _call) {
	writeln ("Visiting Call");
	return _call;
    }

    override protected Expression visitAffect (Affect _aff) {
	writeln ("Visiting Affect");
	return _aff;
    }

    override protected Expression visitBinary (Binary _bin) {
	writeln ("Visiting Binary");
	return _bin;
    }

    override protected Expression visitVar (Var _var) {
	writeln ("Visiting Var");
	return _var;
    }

    override protected Expression visitInt (Int _int) {
	writeln ("Visiting Int");
	return _int;
    }

    override protected Expression visitBool (Bool _bool) {
	writeln ("Visiting Bool");
	return _bool;
    }

}

