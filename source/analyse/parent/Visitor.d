module analyse.parent.Visitor;
import ast.all;
import std.container, std.conv;
import tables.Symbol;
import std.typecons;
import syntax.Word;
import syntax.Tokens;

/++
+ Ancetre des visiteur des autres analyse statique
+/
class Visitor {

    final Program opCall (Program prg) {
	Array!Function funcs;
	Array!Instruction vars;
	Array!Instruction block;
	
	analyse (prg);

	return new Program (prg.id, funcs, vars, block);
    }

    abstract void analyse (Program);
    

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
    
    final private static bool containInAffect (Affect aff, Expression what) {
	if (equals (aff, what)) {
	    return true;
	} else return Visitor.contain (aff.left, what) ||
		   Visitor.contain (aff.right, what);
    }

    final private static bool containInBinary (Binary bin, Expression what) {
	if (equals (bin, what)) {
	    return true;
	} else return Visitor.contain (bin.left, what) ||
		   Visitor.contain (bin.right, what);
	    	
    }
    
    final private static bool containInVar (Var aff, Expression what) {
	if (equals (aff, what)) return true;
	return false;
    }


    final protected ulong init (Instruction inst) {
	if (auto _if = cast (If) inst) return _if.test.id;
	else if (auto _wh = cast (While) inst) return _wh.test.id;
	else if (auto _bl = cast (Block) inst) return init(_bl.insts [0]);
	return inst.id;
    }

    final protected Array!ulong final_ (Instruction inst) {
	if (cast (Expression) inst) return make!(Array!ulong) (inst.id);
	else if (cast (Skip) inst) return make!(Array!ulong) (inst.id);
	else if (auto _if = cast (If) inst) {
	    if (_if.else_)
		return final_ (_if.block) ~ final_ (_if.else_.block); 
	    else
		return final_ (_if.block);
	} else if (auto _wh = cast (While) inst) return make!(Array!ulong) (_wh.test.id);
	else if (auto _bl = cast (Block) inst) {
	    if (_bl.insts.length > 0)
		return final_ (_bl.insts.back ());
	    else return make!(Array!ulong);
	} else assert (false, typeid (inst).toString);
    }

    final protected Array!ulong labels (Instruction inst) {
	if (cast (Expression) inst) return make!(Array!ulong)(inst.id);
	else if (cast (Skip) inst) return make!(Array!ulong) (inst.id);
	else if (auto _if = cast (If) inst) {
	    if (_if.else_)
		return make!(Array!ulong) (_if.test.id) ~ labels (_if.block) ~ labels (_if.else_.block);
	    else
		return make!(Array!ulong) (_if.test.id) ~ labels (_if.block);	    
	} else if (auto _wh = cast (While) inst)
	    return make!(Array!ulong) (_wh.test.id) ~ labels (_wh.block);
	else if (auto _bl = cast (Block) inst) {
	    Array!ulong lab;
	    foreach (it ; _bl.insts) {
		lab ~= labels (it);
	    }
	    return lab;
	} else assert (false, typeid (inst).toString);		
    }

    alias Pair = Tuple!(ulong, ulong);    
    final protected Array!(Pair) flow (Instruction inst) {
	if (cast (Expression) inst) return make!(Array!Pair);
	else if (cast (Skip) inst) return make!(Array!Pair);
	else if (auto _bl = cast (Block) inst) {
	    Array!Pair fin;
	    if (_bl.insts.length > 1) {
		foreach (it ; 0 .. _bl.insts.length - 1) {
		    fin ~= flow (_bl.insts [it]);
		    fin ~= flow (_bl.insts [it + 1]);
		    auto i = init (_bl.insts [it + 1]);
		    auto f = final_ (_bl.insts [it]);
		    foreach (l ; f) {
			fin.insertBack (Pair (l, i));
		    }		    
		}
		return fin;
	    } else if (_bl.insts.length == 1) return flow (_bl.insts [0]);
	    else return make!(Array!Pair);
	} else if (auto _wh = cast (While) inst) {
	    Array!Pair fin;
	    fin ~= flow (_wh.block);
	    fin.insertBack (Pair (_wh.test.id, init (_wh.block)));
	    auto f = final_ (_wh.block);
	    foreach (l_ ; f) {
		fin.insertBack (Pair (l_, _wh.test.id));
	    }
	    return fin;
	} else if (auto _if = cast (If) inst) {
	    Array!Pair fin;
	    fin ~= flow (_if.block);
	    fin.insertBack (Pair (_if.test.id, init (_if.block)));
	    if (_if.else_) {
		fin ~= flow (_if.else_.block);
		fin.insertBack (Pair (_if.test.id, init(_if.else_.block)));
	    }
	    return fin;
	} else assert (false, typeid (inst).toString);
    }

    final protected Array!Pair flow (Program p) {
	Array!Pair fin;
	if (p.begins.length > 1) {
	    foreach (it ; 0 .. p.begins.length - 1) {
		fin ~= flow (p.begins [it]);
		fin ~= flow (p.begins [it + 1]);
		auto i = init (p.begins [it + 1]);
		auto f = final_ (p.begins [it]);
		foreach (l_; f) {
		    fin.insertBack (Pair (l_, i));
		}
	    }
	    return fin;
	} else if (p.begins.length == 1) return flow (p.begins [0]);
	else return make!(Array!Pair);
    }
    
    final protected Array!Expression blocks (Instruction inst) {
	if (auto _exp = cast (Expression) inst) return make!(Array!Expression) (_exp);
	else if (auto _sk = cast (Skip) inst) return make!(Array!Expression);
	else if (auto _bl = cast (Block) inst) {
	    Array!Expression fin;
	    foreach (it ; _bl.insts)
		fin ~= blocks (it);
	    return fin;
	} else if (auto _if = cast (If) inst) {
	    if (_if.else_) 
		return make!(Array!Expression) (_if.test) ~ blocks (_if.block) ~ blocks (_if.else_.block);
	    else 
		return make!(Array!Expression) (_if.test) ~ blocks (_if.block);
	} else if (auto _wh = cast (While) inst) {
	    return make!(Array!Expression) (_wh.test) ~ blocks (_wh.block);
	} else assert (false, typeid (inst).toString);	           
    }   

    final protected Array!Expression blocks (Program prg) {
	Array!Expression fin;
	foreach (it; prg.begins) {
	    fin ~= blocks (it);
	}
	return fin;
    }
    

    final protected bool isTestOp (Word op) {
	return op == Tokens.INF ||
	    op == Tokens.INF_EQ ||
	    op == Tokens.SUP ||
	    op == Tokens.SUP_EQ ||
	    op == Tokens.EQUALS ||
	    op == Tokens.DIFF;
    }
    
}


