module analyse.parent.Visitor;
import ast.all;
import std.container;

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

    
    abstract Expression visitAffect (Affect);
    abstract Expression visitBinary (Binary);
    abstract Expression visitVar (Var);
    abstract Expression visitInt (Int);
    abstract Expression visitBool (Bool);    
}
