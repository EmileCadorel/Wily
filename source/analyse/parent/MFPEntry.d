module analyse.MFPEntry;
import std.container;
import analyse.parent.Visitor;
import ast.Expression;
import ast.Program;
import std.typecons;
import ast.Constante;

struct MFPEntry (T) {

    Program S;
    
    Array!Pair F;

    Array!ulong E;

    Array!T extr;
    
    Array!T not;

    bool function (Array!T, Array!T) inside;

    Array!(T) function (ulong, Program) fl;

    Array!(T) function (Array!T, Array!T) joint;
    
}

