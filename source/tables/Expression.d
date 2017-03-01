module tables.Expression;
import std.container;
import utils.Singleton;
import ast.Expression;
import analyse.parent.Visitor;

/++
+ Cette classe contient toutes les expressions de l'analyse statique
+ Les variables libre des expression, les operation killAE, genAE, killRD, genRD ...
+/

class ExpressionTable {       
    mixin Singleton!ExpressionTable;

    private Array!Expression _expr;

    public ref Array!Expression expr () {
	return _expr;
    }

    public Array!Expression killAE (Expression expr) {
	Array!Expression res;
	foreach (it ; _expr)
	    if (Visitor.contain (it, expr)) res.insertBack (it);
	return res;
    }

    public Array!Expression genAE (Expression expr1, Expression expr2) {
	Array!Expression res;
	foreach (it ; _expr)
	    if (!Visitor.contain (it, expr1) && Visitor.contain (it, expr2)) res.insertBack (it);
	return res;
    }
}
