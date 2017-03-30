module analyse.valide.Visitor;
import parent = analyse.parent.Visitor;
import std.stdio, std.container;
import ast.all;
import tables.Symbol;
import syntax.Keys;
import std.algorithm;
import std.string, std.outbuffer;
import std.conv;
import std.typecons;
import analyse.MFPEntry;
import utils.Colors;

alias Location = parent.Location;


class Visitor : parent.Visitor {

    private static Array!ulong dones;    

    final private void printUse (Var elem) {
	writef ("%sAttention%s : (%d, %d)", Colors.YELLOW.value, Colors.RESET.value,
		    elem.token.locus.line, elem.token.locus.column);
	writefln ("Utilisation d'une variable potentiellement non initialisé : %s",
		   elem.token.str);
    }
    
    final private void test (Program p, Expression elem, Array!Location entry) {
	auto vars = FV (elem);
	foreach (it ; vars) {
	    bool find = false;
	    foreach (it_ ; entry) {
		if (equals (it_.v, it) && it_.l == -1) {
		    find = true;
		    break;
		}
	    }
	    
	    if (find)
		printUse (it);
	}
    }

    override void analyse (Program p) {
	// write (" ===", center ("entry", 32, '='));
	// writeln (center ("exit", 32, '='));
	// foreach (it ; blocks (p)) {
	//     auto kill = RDentry (it, p);
	//     dones.clear ();
	//     auto gen = RDexit (it.id, p);
	//     print (kill);
	//     print (gen);
	//     writeln ("");
	// }
	
	// writeln (" ===", center ("", 64, '='));
	
	
	MFPEntry!Location mfpEntry;
	mfpEntry.F = flow (p);
	mfpEntry.E = make!(Array!ulong) (init (p));
	mfpEntry.not = make!(Array!Location) ([Location (null, -1)]);
	mfpEntry.extr = FVLocation (p);
	mfpEntry.S = p;

	mfpEntry.inside = function (Array!Location left, Array!Location right) {
	    if (right.length == 1 && right [0].v is null)  return false;
	    foreach (it ; left) {
		if (find(right [], it).empty) return false;
	    }
	    return true;
	};

	mfpEntry.fl = function (ulong id, Program p) {
	    return RDexit (id, p);
	};

	mfpEntry.joint = function (Array!Location left, Array!Location right) {
	    if (right.length == 1 && right [0].v is null) return left;
	    return simplify (add (left, right));
	};

	auto res = MFP (mfpEntry);
	foreach (it, value; res [0]) {
	    test (p, cast (Expression) (get (it, p)), value);
	}
    }
    
    static Array!Location killRD (Expression expr, Program p) {
	Array!Location ret;
	if (auto _aff = cast (Affect) expr) {
	    ret.insertBack (Location (cast (Var) _aff.left, -1));
	    foreach (it ; blocks (p)) {
		if (auto _aff2 = cast (Affect) it) {
		    if (_aff2.left.token.str ==_aff.left.token.str)
			ret.insertBack (Location (cast (Var) _aff2.left, _aff2.id));
		}
	    }
	}
	return ret;
    }

    static Array!Location genRD (Expression expr, Program p) {
	if (auto _aff = cast (Affect) expr) {
	    return make!(Array!Location) ([Location(cast (Var) _aff.left, _aff.id)]);
	} return make!(Array!Location);
    }
    
    static Array!Location RDentry (Instruction current, Program p) {
	dones.clear ();
	return RDentry2 (current, p);
    }
    
    static Array!Location RDentry2 (Instruction current, Program p) {
	if (current.id == init (p.begins [0])) {
	    return simplify (FVLocation (p)); 
	} else {
	    auto fl = flow (p);
	    Array!ulong toDo;
	    foreach (it ; fl) {		
		if (it [1] == current.id && find (dones [], it [0]).empty)
		    toDo.insertBack (it [0]);
	    }
	    
	    dones.insertBack (current.id);
	    
	    Array!Location total;
	    foreach (it ; toDo) {
		total = add (total, RDexit2 (it, p));
	    }
	    return simplify (total);
	}	
    }
       
    static Array!Location RDexit (ulong id, Program p) {
	dones.clear ();
	return RDexit2 (id, p);
    }       


    static Array!Location RDexit2 (ulong id, Program p) {
	auto inst = get (id, p);
	auto entry = RDentry2 (inst, p);
	auto bls = blocks (inst);
	foreach (it ; bls) {
	    auto kill = killRD (it, p);
	    auto gen = genRD (it, p);
	    entry = sub (entry, kill);
	    entry = add (entry, gen);
	}
	return simplify (entry);
    }       
    

    static Array!Location FVLocation (Program p) {
	Array!Location v;
	foreach (it ; blocks (p)) {
	    v ~= FVLocation (it);
	}
	return v;
    }

    static Array!Location FVLocation (Expression expr) {
	if (auto _aff = cast (Affect) expr) {
	    return FVLocation (_aff.right);
	} else if (auto _bin = cast (Binary) expr) {
	    return FVLocation (_bin.left) ~ FVLocation (_bin.right);
	} else if (auto _var = cast (Var) expr) {
	    return make!(Array!Location) (Location (_var, -1));
	}
	return make!(Array!Location);
    }

}
