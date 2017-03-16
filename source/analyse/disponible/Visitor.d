module analyse.disponible.Visitor;

import parent = analyse.parent.Visitor;
import std.stdio, std.container;
import ast.all;
import tables.Symbol;
import syntax.Keys;
import std.algorithm;
import std.string, std.outbuffer;
import std.conv;
import std.typecons;

class Visitor : parent.Visitor {
    
    private Array!ulong dones;    
    
    private void printEEElems (ulong id, Array!Expression entry, Array!Expression exit) {
	writef ("|%s", center (to!string (id), 3, ' '));
	auto buf = new OutBuffer ();
	buf.write ("{");
	foreach (it ; entry) {
	    buf.writef ("%d:", it.id);
	    it.prettyPrint (buf);
	    if (it !is entry [$ - 1])
		buf.write (", ");
	}
	buf.write ("}");
	
	auto buf2 = new OutBuffer ();
	buf2.write ("{");
	foreach (it ; exit) {
	    buf2.writef ("%d:", it.id);
	    it.prettyPrint (buf2);
	    if (it !is exit [$ - 1])
		buf2.write (", ");
	}
	buf2.write ("}");
	writefln ("|%s|%s|",
		  center (buf.toString (), 50, ' '),
		  center (buf2.toString (), 50, ' '));
	
    }

    private void print (Array!Expression elems) {
	auto buf2 = new OutBuffer ();
	buf2.write ("{");
	foreach (it ; elems) {
	    buf2.writef ("%d:", it.id);
	    it.prettyPrint (buf2);
	    if (it !is elems [$ - 1])
		buf2.write (", ");
	}
	buf2.write ("}");
	writefln ("|%s|",
		  center (buf2.toString (), 20, ' '));
    }
    

    final private void change (Program p, Expression elem, Array!Expression entry) {
	if (auto _aff = cast (Affect) elem) {
	    foreach (it ; entry) {
		if (equals (_aff.right, it)) {
		    _aff.right = getParent (it.id, p).left;
		    break;
		}
	    }
	} else if (auto _bin = cast (Binary) elem) {
	    foreach (it ; entry) {
		if (equals (_bin.right, it))
		    _bin.right = getParent (it.id, p).left;
	    }
	} 
    }

    override void analyse (Program p) {
	write (center ("===entry", 43, '='));
	writeln (center ("exit", 43, '='));
	foreach (it ; blocks (p)) {
	    Array!Expression entry, exit;
	    dones.clear ();
	    entry = AEentry (it, p);
	    dones.clear ();
	    //exit = AEexit (it.id, p);
	    printEEElems (it.id, entry, exit);
	    change (p, it, entry);
	}
	
	writeln (center ("", 47, '='));
	p.prettyPrint ();
    }
    
    private Array!Expression AExp (Instruction inst) {
	if (auto _if = cast (If) inst) {	    
	    auto ret = AExp (_if.test) ~ AExp (_if.block);
	    if (_if.else_) ret ~= AExp (_if.else_.block);
	    return ret;
	} else if (auto _wh = cast (While) inst) {
	    return AExp (_wh.test) ~ AExp (_wh.block);
	} else if (auto _bl = cast (Block) inst) {
	    Array!Expression ret;
	    foreach (it ; _bl.insts) {
		ret ~= AExp (it);
	    }
	    return ret;
	} else if (auto _aff = cast (Affect) inst) return make!(Array!Expression) (_aff);
	else if (auto _bin = cast (Binary) inst) return make!(Array!Expression) (_bin);
	else return make!(Array!Expression);
    }
    
    private Array!Expression AExp (Program p) {
	Array!Expression ret;
	foreach (it ; p.begins) {
	    ret ~= AExp (it);
	}
	return ret;
    }
    
    private Array!Var FV (Expression expr) {
	if (auto _aff = cast (Affect) expr) {
	    return FV (_aff.right);
	} else if (auto _bin = cast (Binary) expr) {
	    return FV (_bin.left) ~ FV (_bin.right);
	} else if (auto _var = cast (Var) expr) {
	    return make!(Array!Var) (_var);
	}
	return make!(Array!Var);
    }

    private Array!Expression killAE (Expression expr, Program p) {
	if (auto _aff = cast (Affect) expr) {
	    auto aexp = AExp (p);
	    Array!Expression ret;
	    foreach (it ; aexp) {
		if (auto _aff_ = cast (Affect) it)
		    it = _aff_.right;
		auto fv = FV (it);
		if (!find!("a.token.str == b.token.str") (fv [], _aff.left).empty)
		    ret.insertBack (it);
	    }
	    return ret;
	} else return make!(Array!Expression);
    }

    private Array!Expression genAE (Expression expr, Program p) {
	if (auto _aff = cast (Affect) expr) {
	    auto aexp = AExp (_aff.right);
	    Array!Expression ret;
	    foreach (it ; aexp) {
		auto fv = FV (it);			 
		if (find!("a.token.str == b.token.str") (fv [], _aff.left).empty)
		    ret.insertBack (it);
	    }
	    return ret;	    
	} else	return AExp (expr);	
    }
    
    private Array!Expression intersect (Array!Expression fst, Array!Expression scd) {
	Array!Expression back;
	foreach (it ; fst) {
	    foreach (it_ ; scd) {
		if (equals (it, it_)) back.insertBack (it);
		break;
	    }
	}
	return back;
    }    

    private Array!Expression sub (Array!Expression fst, Array!Expression scd) {
	Array!Expression back;
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
    
    private Array!Expression add (Array!Expression fst, Array!Expression scd) {
	Array!Expression back;
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

    private Array!Expression simplify (Array!Expression elem) {
	Array!Expression back;
	foreach (it; elem) {
	    if (find!(function (Expression a, Expression b) => equals (a, b))(back [], it).empty)
		back.insertBack (it);
	}
	return back;
    }    
    
    private Array!Expression AEentry (Instruction current, Program p) {
	if (current.id == init (p.begins [0])) {
	    return make!(Array!Expression);
	} else {
	    Array!(Array!Expression) toInter;
	    auto f = flow (p);
	    Array!ulong toDo;
	    foreach (it ; f) {
		if (it [1] == current.id && find (dones [], it [0]).empty) {
		    toDo.insertBack (it [0]);
		}
	    }

	    dones.insertBack (current.id);
	    
	    foreach (it ; toDo) {
		toInter.insertBack (AEexit (it, p));
	    }
	    
	    while (toInter.length > 1) {
		auto back  = intersect (toInter [$ - 1], toInter [$ - 2]);
		toInter.removeBack ();
		toInter.removeBack ();
		toInter.insertBack (back);
	    }
	    
	    if (toInter.length != 0) {
		return toInter [$ - 1];
	    }
	    else return make!(Array!Expression);
	}
    }

    private Instruction get (ulong id, Instruction inst) {
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

    
    private Affect getParent (ulong id, Instruction inst) {
	if (auto _if = cast (If) inst) {
	    if (auto it = getParent (id, _if.block)) return it;
	    if (_if.else_)
		if (auto it = getParent (id, _if.else_.block)) return it;
	    return null;
	} else if (auto _wh = cast (While) inst) {
	    return getParent (id, _wh.block);
	} else if (auto _bl = cast (Block) inst) {
	    foreach (it ; _bl.insts) {
		if (auto ins = getParent (id, it)) return ins;
	    }
	    return null;
	} else if (auto _aff = cast (Affect) inst) {
	    if (_aff.right.id == id) return _aff;
	    return null;
	} else return null;
    }
   
    private Affect getParent (ulong id, Program p) {
	foreach (it ; p.begins) {
	    if (auto inst = getParent (id, it)) return inst;
	}
	return null;
    }

    private Instruction get (ulong id, Program p) {
	foreach (it ; p.begins) {
	    if (it.id == id) return it;
	    else if (auto inst = get (id, it)) return inst;
	}
	return null;
    }
 
    private Array!Expression AEexit (ulong id, Program p) {
	auto inst = get (id, p);
	auto entry = AEentry (inst, p);
	auto bls = blocks (inst);
	foreach (it ; bls) {
	    auto kill = killAE (it, p);
	    auto gen = genAE (it, p);
	    entry = sub (entry, kill);
	    entry = add (entry, gen);
	    entry = simplify (entry);
	}
	return entry;
    }
    
}

