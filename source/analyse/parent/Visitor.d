module analyse.parent.Visitor;
import ast.all;
import std.container, std.conv;

/++
+ Ancetre des visiteur des autres analyse statique
+/
class Visitor {

    final public Program visit (Program prg) {
	Array!Function funcs;
	Array!Instruction vars;
	Array!Instruction block;
	
	foreach (it ; prg.decls) {
	    funcs.insertBack (visit (it));
	}

	foreach (it ; prg.vars) {
	    vars.insertBack (visit(it));
	}

	foreach (it ; prg.begins) {
	    block.insertBack (visit (it));
	}

	return new Program (prg.id, funcs, vars, block);
    }

    abstract Function visit (Function);    
    
    final protected Instruction visit (Instruction inst) {
	if (auto _if = cast (If) inst) return visitIf (_if);
	else if (auto _while = cast (While) inst) return visitWhile (_while);
	else if (auto _call = cast (Call) inst) return visitCall (_call);
	else if (auto _expr = cast (Expression) inst) return visit (_expr);
	else assert (false, typeid(inst).toString);
    }

    abstract Instruction visitIf (If);
    abstract Instruction visitWhile (While);
    abstract Instruction visitCall (Call);
    
    final protected Expression visit (Expression expr) {
	if (auto _aff = cast (Affect) expr) return visitAffect (_aff);
	else if (auto _bin = cast (Binary) expr) return visitBinary (_bin);
	else if  (auto _var = cast (Var) expr) return visitVar (_var);
	else if (auto _int = cast (Int) expr) return visitInt (_int);
	else if (auto _bool = cast (Bool) expr) return visitBool (_bool);
	else assert (false, typeid(expr).toString);
    }


    final private static bool match (T, Fun : bool function (T, T)) (Expression left, Expression right, Fun fun) {
	auto _le = cast (T) left, _ri = cast (T) right;	
	if (_le && _ri) return fun (_le, _ri);
	return false;
    }
    
    final static bool equals (Expression left, Expression right) {
	if (match!Affect (left, right, &equalsAffect)) return true;
	else if (match!Binary (left, right, &equalsBinary)) return true;
	else if (match!Var (left, right, &equalsVar)) return true;
	else if (match!Int (left, right, &equalsInt)) return true;
	else if (match!Bool (left, right, &equalsBool)) return true;
	else return false;
    }

    final static private bool equalsAffect (Affect left, Affect right) {
	return equals (left.left, right.left) && equals (left.right, right.right);
    }
    
    final static private bool equalsBinary (Binary left, Binary right) {
	return left.token.str == right.token.str &&
	    equals (left.left, right.left) &&
	    equals (left.right, right.right);
    }
    
    final static private bool equalsVar (Var left, Var right) {
	return left.token.str == right.token.str;
    }
    
    final static private bool equalsInt (Int left, Int right) {
	return to!long (left.token.str) == to!long (right.token.str);
    }

    final static private bool equalsBool (Bool left, Bool right) {
	return left.token.str == right.token.str;
    }    
    
    final static bool contain (Expression where, Expression what) {
	if (auto _aff = cast (Affect) where) return containInAffect (_aff, what);
	else if (auto _bin = cast (Binary) where) return containInBinary (_bin, what);
	else if (auto _var = cast (Var) where) return containInVar (_var, what);
	else if (cast (Int) where) return false;
	else if (cast (Bool) where) return false;
	else assert (false, typeid (where).toString);
    }    
    
    private static bool containInAffect (Affect aff, Expression what) {
	if (equals (aff, what)) {
	    return true;
	} else return Visitor.contain (aff.left, what) ||
		   Visitor.contain (aff.right, what);
    }

    private static bool containInBinary (Binary bin, Expression what) {
	if (equals (bin, what)) {
	    return true;
	} else return Visitor.contain (bin.left, what) ||
		   Visitor.contain (bin.right, what);
	    	
    }
    
    private static bool containInVar (Var aff, Expression what) {
	if (equals (aff, what)) return true;
	return false;
    }
    
    
    abstract Expression visitAffect (Affect);
    abstract Expression visitBinary (Binary);
    abstract Expression visitVar (Var);
    abstract Expression visitInt (Int);
    abstract Expression visitBool (Bool);    
}


unittest {
    import std.stdio;
    import utils.Colors, syntax.Word;
    import ast.all;
    
    immutable string fail = Colors.RED.value ~ "Test Visitor fail" ~ Colors.RESET.value;
    auto a = Word.eof, b = Word.eof;
    a.str = "a"; b.str = "b";
    
    auto varA = new Var (a), varB = new Var (b);
    assert (!Visitor.equals (varA, varB), fail);
    assert (Visitor.equals (varA, varA), fail);

    
    auto aff = new Affect (Word.eof, varA, varB);
    assert (Visitor.contain (aff, varA), fail);

    auto binT = Word (Location (0, 0, 1, "", false), "+");
    auto dec = Word (Location (0, 0, 3, "", false), "123");
    auto bin = new Binary (binT, varA, varB);
    
    auto bin2 = new Binary (binT, bin, new Int (dec));
    assert (Visitor.contain (bin2, varB), fail);

    writeln (Colors.GREEN.value, "Test Visitor pass", Colors.RESET.value);
}
