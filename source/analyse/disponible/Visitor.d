module analyse.disponible.Visitor;

import parent = analyse.parent.Visitor;
import std.stdio, std.container;
import ast.all;
import tables.Symbol;
import syntax.Keys;

class Visitor : parent.Visitor {

    override protected VarDecl visitVarDecl (VarDecl decl) {
	Array!Symbol symbols;
	auto type = decl.type;	
	foreach (it ; decl.names) {
	    Symbol sym;
	    if (type == Keys.INT) sym = new Symbol (it, INT);		
	    else sym = new Symbol (it, BOOL);
	    SymbolTable.instance.addSymbol (sym);
	    symbols.insertBack (sym);
	}
	return new VarDecl (type, decl.names, symbols);
    }
    
    override protected Instruction visitIf (If _if) {	
	return _if;
    }

    override protected Instruction visitWhile (While _while) {
	writeln ("Visiting While");
	auto i = init (_while);
	auto f = final_ (_while);
	auto b = blocks (_while);
	auto fl = flow (_while);
	auto l = labels (_while);
	writeln ("Init:", i);

	write ("Final:{");
	foreach (it ; f) {
	    write (it);
	}
	writeln ("}");

	write ("Flow:{");
	foreach (it ; fl) {
	    write ("(", it[0], ",", it[1], ")");
	}
	writeln ("}");
	
	write ("Blocks:{");
	foreach (it ; b) {
	    write ("(", it.id, ")");
	}
	writeln ("}");
	
	write ("Labels:{");
	foreach (it ; l) {
	    write ("(", it, ")");
	}
	writeln ("}");

	
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

