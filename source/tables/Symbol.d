module tables.Symbol;
import utils.Singleton;


/++
+ Cette classe contient tous les symboles déclarer dans le programme
+ Il que des scopes de fonction donc pas tres complique
+/
class SymbolTable {


    mixin Singleton!SymbolTable;
}
