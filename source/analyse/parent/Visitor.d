module analyse.parent.Visitor;
import ast.all;
import std.container, std.conv;
import tables.Symbol;
import std.typecons;
import syntax.Word;
import syntax.Tokens;
import analyse.MFPEntry;
import std.stdio;
import std.string;
import std.math, std.algorithm;
import analyse.valide.Visitor;
import ast.Constante;

alias Pair = Tuple!(ulong, ulong);    

alias Location = Tuple!(Var, "v", long, "l"); 


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
    
    final static bool equals (Location left, Location right) {
	return left.v.token.str == right.v.token.str && right.l == left.l;
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


    final static ulong init (Program p) {
	return init (p.begins [0]);
    }
    
    final static ulong init (Instruction inst) {
	if (auto _if = cast (If) inst) return _if.test.id;
	else if (auto _wh = cast (While) inst) return _wh.test.id;
	else if (auto _bl = cast (Block) inst) return init(_bl.insts [0]);
	return inst.id;
    }

    final static Array!ulong final_ (Instruction inst) {
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

    final static Array!ulong labels (Instruction inst) {
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


    final static Array!(Pair) flow (Instruction inst) {
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

    final static Array!Pair flow (Program p) {
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
    
    final static Array!Expression blocks (Instruction inst) {
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

    final static Array!Expression blocks (Program prg) {
	Array!Expression fin;
	foreach (it; prg.begins) {
	    fin ~= blocks (it);
	}
	return fin;
    }


    static void print (Array!Expression elems) {
	auto buf2 = new OutBuffer ();
	buf2.write ("{");
	foreach (it ; elems) {
	    if (it is null) { buf2.writef ("T"); break; }
	    buf2.writef ("%d:", it.id);
	    it.prettyPrint (buf2);
	    if (it !is elems [$ - 1])
		buf2.write (", ");
	}
	buf2.write ("}");
	writef ("|%s|",
		  center (buf2.toString (), 32, ' '));
    }

    static void print (Array!Location elems) {
	auto buf2 = new OutBuffer ();
	buf2.write ("{");
	foreach (it ; elems) {
	    if (it.v is null) { buf2.writef ("T"); break; }
	    buf2.write ("(");
	    it.v.prettyPrint (buf2);
	    buf2.writef (":%d)", it.l);
	    if (it !is elems [$ - 1])
		buf2.write (", ");
	}
	buf2.write ("}");
	writef ("|%s|",
		  center (buf2.toString (), 32, ' '));
    }


    
    static Array!Expression FV (Program p) {
	Array!Expression v;
	foreach (it ; blocks (p)) {
	    v ~= FV (it);
	}
	return v;
    }
    
    static Array!Var FV (Expression expr) {
	if (auto _aff = cast (Affect) expr) {
	    return FV (_aff.right);
	} else if (auto _bin = cast (Binary) expr) {
	    return FV (_bin.left) ~ FV (_bin.right);
	} else if (auto _var = cast (Var) expr) {
	    return make!(Array!Var) (_var);
	}
	return make!(Array!Var);
    }

    
    final static void printAnalysisHead (T) (Array!(T) [ulong] Analysis, SList!Pair W) {	
	foreach (it, value ; Analysis) {
	    writef ("|%s|", center (to!string (it), 32, ' '), " ");
	}
	writeln ("");
	foreach (it, value; Analysis) {
	    print (value);
	}
	write ('[');
	foreach (it ; W) {
	    write (it [0], ',', it [1], " ");
	}
	writeln ("]");
    }    

    
    final static void printAnalysis (T) (Array!(T) [ulong] Analysis, SList!Pair W) {
	foreach (it, value; Analysis) {
	    print (value);
	}
	write ('[');
	foreach (it ; W) {
	    write (it [0], ',', it [1], " ");
	}
	writeln ("]");
    }    
    
    final static auto MFP (T)(MFPEntry!T params) {
	SList!Pair W;
	foreach (it; params.F) {
	    W.insertFront (it);
	}

	Array!(T) [ulong] Analysis;
	
	foreach (it; params.F) {	    
	    if (!find (params.E [], it [0]).empty) {
		Analysis [it [0]] = params.extr;
	    } else {		
		Analysis [it [0]] = (params.not);
	    }

	    if (!find (params.E [], it [1]).empty) {
		Analysis [it [1]] = params.extr;
	    } else {
		Analysis [it [1]] = (params.not);
	    }	    
	}

	foreach (it ; params.E) {
	    Analysis [it] = params.extr;
	}

	printAnalysisHead (Analysis, W);
	
	while (!W.empty) {
	    auto head = W.front;
	    W.removeFront ();
	    auto fl = params.fl (head [0], params.S);
	    if (!params.inside (fl, Analysis [head [1]])) {		
		Analysis [head [1]] = params.joint (fl, Analysis [head [1]]);
		foreach (w ; params.F) {
		    if (w [0] == head [1]) {
			W.insertFront (w);
		    }
		}
	    }
	    printAnalysis (Analysis, W);
	}
	
	return ResultatMFP (Analysis, params);
    }


    
    final static auto ResultatMFP (T) (Array!(T) [ulong] Analysis, MFPEntry!T params) {
	alias Tuple!(Array!(T) [ulong], Array!(T) [ulong]) Result;
	Array!(T) [ulong] MFPB;
	Array!(T) [ulong] MFPW;
	
	foreach (it ; params.F) {
	    MFPW [it [0]] = Analysis [it [0]];
	    MFPW [it [1]] = Analysis [it [1]];

	    MFPB [it [0]] = params.fl (it [0], params.S);
	    MFPB [it [1]] = params.fl (it [1], params.S);
	}

	foreach (it ; params.E) {
	    MFPW [it] = Analysis [it];
	    MFPB [it] = params.fl (it, params.S);
	}
	
	return Result (MFPW, MFPB);
    }    


    
    static Array!T intersect (T) (Array!T fst, Array!T scd) {
	Array!T back;
	foreach (it ; fst) {
	    foreach (it_ ; scd) {
		if (equals (it, it_)) back.insertBack (it);
		break;
	    }
	}
	return back;
    }    

    static Array!T sub (T) (Array!T fst, Array!T scd) {
	Array!T back;
	foreach (it ; fst) {
	    bool add = true;
	    foreach (it_ ; scd) {
		if (equals (it, it_)) {
		    add = false;
		    break;
		}
	    }
	    if (add) back.insertBack (it);
	    
	}
	return back;
    }
    
    static Array!T add (T) (Array!T fst, Array!T scd) {
	Array!T back;
	foreach (it ; scd) back.insertBack (it);
	foreach (it ; fst) {
	    bool add = true;
	    foreach (it_ ; scd) {
		if (equals (it, it_)) {
		    add = false;
		    break;
		}
	    }
	    if (add) back.insertBack (it);	    
	}
	return back;    
    }

    static Array!T simplify (T) (Array!T elem) {
	Array!T back;
	foreach (it; elem) {
	    if (find!(function (T a, T b) => equals (a, b))(back [], it).empty)
		back.insertBack (it);
	}
	return back;
    }    

    
    static Instruction get (ulong id, Instruction inst) {
	if (auto _if = cast (If) inst) {
	    if (_if.test.id == id) return _if.test;
	    if (auto it = get (id, _if.block)) return it;
	    if (_if.else_)
		if (auto it = get (id, _if.else_.block)) return it;
	    return null;
	} else if (auto _wh = cast (While) inst) {
	    if (_wh.test.id == id) return _wh.test;
	    return get (id, _wh.block);
	} else if (auto _bl = cast (Block) inst) {
	    foreach (it ; _bl.insts) {
		if (it.id == id) return it;
		else if (auto ins = get (id, it)) return ins;
	    }
	    return null;
	}  else return null;
    }

    static Instruction get (ulong id, Program p) {
	foreach (it ; p.begins) {
	    if (it.id == id) return it;
	    else if (auto inst = get (id, it)) return inst;
	}
	return null;
    }

    
    final static bool isTestOp (Word op) {
	return op == Tokens.INF ||
	    op == Tokens.INF_EQ ||
	    op == Tokens.SUP ||
	    op == Tokens.SUP_EQ ||
	    op == Tokens.EQUALS ||
	    op == Tokens.DIFF;
    }
    
}


