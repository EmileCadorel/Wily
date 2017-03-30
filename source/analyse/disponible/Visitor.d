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
    
    private static Array!ulong dones;    
    
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
		    return;
		}
	    }
	    change (p, _aff.right, entry);
	    
	} else if (auto _bin = cast (Binary) elem) {
	    bool left = false, right = false;
	    foreach (it ; entry) {
		if (left && right) break;
		if (equals (_bin.right, it) && !right) {
		    _bin.right = getParent (it.id, p).left;
		    right = true;
		} else if (equals (_bin.left, it) && !left) {
		    _bin.left = getParent (it.id, p).left;
		    left = true;
		}
	    }

	    if (!left)
		change (p, _bin.left, entry);
	    
	    if (!right)
		change (p, _bin.right, entry);	    
	} 
    }

    override void analyse (Program p) {
	import analyse.MFPEntry;
	MFPEntry!Expression mfp_entry;
	mfp_entry.F = flow (p);
	mfp_entry.E = make!(Array!ulong) (init (p));
	mfp_entry.not = make!(Array!Expression) ([null]);
	mfp_entry.extr = make!(Array!Expression) ();
	mfp_entry.S = p;
	
	mfp_entry.inside = function (Array!Expression left, Array!Expression right) {
	    if (right.length == 1 && right [0] is null)  return false;
	    foreach (it ; right) {
		if (find(left [], it).empty) return false;
	    }
	    return true;
	};

	mfp_entry.fl = function (ulong id, Program p) {
	    return AEexit (id, p);
	};
	
	mfp_entry.joint = function (Array!Expression left, Array!Expression right) {
	    if (right.length == 1 && right [0] is null) return left;
	    return intersect (left, right);
	};
	
	auto res = MFP (mfp_entry);
	foreach (it, value ; res [0]) {
	    change (p, cast (Expression) (get (it, p)), value);
	}    
	
	writeln (" ===", center ("", 102, '='));
	p.prettyPrint ();
    }
    
    static Array!Expression AExp (Instruction inst) {
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
    
    static Array!Expression AExp (Program p) {
	Array!Expression ret;
	foreach (it ; p.begins) {
	    ret ~= AExp (it);
	}
	return ret;
    }
    
    static Array!Expression killAE (Expression expr, Program p) {
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

    static Array!Expression genAE (Expression expr, Program p) {
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

    static Array!Expression AEentry (Instruction current, Program p) {
	dones.clear ();
	return AEentry2 (current, p);
    }
    
    static Array!Expression AEentry2 (Instruction current, Program p) {
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
		toInter.insertBack (AEexit2 (it, p));
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

    
    static Affect getParent (ulong id, Instruction inst) {
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
   
    static Affect getParent (ulong id, Program p) {
	foreach (it ; p.begins) {
	    if (auto inst = getParent (id, it)) return inst;
	}
	return null;
    }
 
    static Array!Expression AEexit (ulong id, Program p) {
	dones.clear ();
	return AEexit2 (id, p);
    }

    static Array!Expression AEexit2 (ulong id, Program p) {
	auto inst = get (id, p);
	auto entry = AEentry2 (inst, p);
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

