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
}
