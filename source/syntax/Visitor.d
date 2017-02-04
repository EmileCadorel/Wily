module syntax.Visitor;
import syntax.Lexer;
import syntax.Word, syntax.Keys;
import syntax.Tokens, syntax.SyntaxError;
import std.stdio, std.outbuffer;
import ast.all, std.container;
import std.algorithm, std.conv;
import std.math;

class Visitor {


    private Lexer _lex;
    private Token[] _expOp;
    private Token[] _highOp;

    private Token[] _suiteElem;
    private Token[] _forbiddenIds;
    
    this (string file) {
	this._lex = new Lexer (file,
			       [Tokens.SPACE, Tokens.RETOUR, Tokens.RRETOUR, Tokens.TAB],
			       []);	
	this._expOp = [];	
	this._highOp = [Tokens.PLUS, Tokens.MINUS];	
	this._suiteElem = [];
	this._forbiddenIds = [];
    }

    /**
     program := function | import | struct | class;
     */
    Program visit () {
	auto begin = _lex.next ();
	Word ident;
	Array!Function decls;
	Array!Instruction insts, begins;
	
	if (begin != Keys.PROGRAM) throw new SyntaxError (begin, [Keys.PROGRAM.descr]);
	auto next = _lex.next ();
	if (next != Keys.BEGIN && next != Keys.PROC) {
	    _lex.rewind ();
	    ident = visitIdentifiant ();
	    next = _lex.next ();
	}

	while (next == Keys.PROC) {
	    decls.insertBack (visitFunction ());
	    next = _lex.next ();
	    if (next == Keys.BEGIN) break;
	    else if (next != Keys.PROC) throw new SyntaxError (next, [Keys.BEGIN.descr, Keys.PROC.descr]);
	}

	if (next != Keys.BEGIN) throw new SyntaxError (next, [Keys.BEGIN.descr]);
	next = _lex.next ();

	while (next == Keys.INT || next == Keys.BOOL) {
	    begins.insertBack (visitVarDecl (next));
	    next = _lex.next ();
	    if (next != Keys.INT && next != Keys.BOOL)
		_lex.rewind ();
	}

	while (true) {
	    next = _lex.next ();
	    if (next == Keys.IF) insts.insertBack (visitIf ());
	    else if (next == Keys.WHILE) insts.insertBack (visitWhile ());
	    else if (next == Keys.CALL) insts.insertBack (visitCall ());
	    else if (next == Keys.END) break;
	    else {
		_lex.rewind ();
		insts.insertBack (visitExpressionUlt ());
	    }
	}
	return new Program (ident, decls, begins, insts);
    }

    private VarDecl visitVarDecl (Word type) {
	Array!Word names;	
	while (true) {
	    names.insertBack (visitIdentifiant ());
	    auto next = _lex.next ();
	    if (next == Tokens.SEMI_COLON) break;
	    else if (next != Tokens.COMA) throw new SyntaxError (next, [Tokens.SEMI_COLON.descr, Tokens.COMA.descr]);
	}
	return new VarDecl (type, names);
    }

    private VarDecl visitVarDeclUnique (Word type) {
	return new VarDecl (type, make!(Array!Word) (visitIdentifiant ()));
    }
   
    private Call visitCall () {
	auto id = visitIdentifiant ();
	auto par = _lex.next ();
	Array!Expression params;
	if (par != Tokens.LPAR) throw new SyntaxError (par, [Tokens.LPAR.descr]);
	while (true) {
	    params.insertBack (visitExpression ());
	    auto next = _lex.next ();
	    if (next == Tokens.RPAR) break;
	    else if (next != Tokens.COMA) throw new SyntaxError (next, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	}
	return new Call (id, params);
    }    
    
    private Function visitFunction () {
	auto id = visitIdentifiant ();
	auto par = _lex.next ();
	Array!VarDecl params;
	VarDecl ret = null;
	if (par != Tokens.LPAR) throw new SyntaxError (par, [Tokens.LPAR.descr]);
	while (true) {
	    auto next = _lex.next ();
	    if (next == Keys.BOOL || next == Keys.INT) params.insertBack (visitVarDeclUnique (next));
	    else if (next == Keys.RES) {
		next = _lex.next ();
		if (next != Keys.BOOL || next != Keys.INT) throw new SyntaxError (next, [Keys.BOOL.descr, Keys.INT.descr]);
		ret = visitVarDeclUnique (next);
		next = _lex.next ();
		if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
		break;
	    } else throw new SyntaxError (next, [Keys.BOOL.descr, Keys.INT.descr, Keys.RES.descr]);
	    
	    next = _lex.next ();
	    if (next == Tokens.RPAR) break;
	    else if (next != Tokens.COMA) throw new SyntaxError (next, [Tokens.RPAR.descr, Tokens.COMA.descr]);
	}

	Array!Instruction insts;
	auto beg = _lex.next ();
	if (beg != Keys.BEGIN) throw new SyntaxError (beg, [Keys.BEGIN.descr]);
	while (true) {
	    auto next = _lex.next ();
	    if (next == Keys.IF) insts.insertBack (visitIf ());
	    else if (next == Keys.WHILE) insts.insertBack (visitWhile ());
	    else if (next == Keys.CALL) insts.insertBack (visitCall ());
	    else if (next == Keys.SKIP) insts.insertBack (visitSkip ());
	    else if (next == Keys.END) break;
	    else {
		_lex.rewind ();
		insts.insertBack (visitExpressionUlt ());
	    }
	}
	return new Function (id, params, ret, insts);
    }    

    private Var visitVar () {
	return new Var (visitIdentifiant ());
    }
    
    /**
     Identifiant := ('_')* ([a-z]|[A-Z]) ([a-z]|[A-Z]|'_')|[0-9])*
     */
    private Word visitIdentifiant () {
	auto ident = _lex.next ();	
	if (ident.isToken ())
	    throw new SyntaxError (ident, ["'Identifiant'"]);
	
	if (find !"b == a" (this._forbiddenIds, ident) != [])
	    throw new SyntaxError (ident, ["'Identifiant'"]);
	
	if (ident.str.length == 0) throw new SyntaxError (ident, ["'Identifiant'"]);
	auto i = 0;
	foreach (it ; ident.str) {
	    if ((it >= 'a' && it <= 'z') || (it >= 'A' && it <= 'Z')) break;
	    else if (it != '_') throw new SyntaxError (ident, ["'identifiant'"]);
	    i++;
	}
	i++;
	if (ident.str.length < i)
	    throw new SyntaxError (ident, ["'Identifiant'"]);
	
	foreach (it ; ident.str [i .. $]) {
	    if ((it < 'a' || it > 'z')
		&& (it < 'A' || it > 'Z')
		&& (it != '_')
		&& (it < '0' || it > '9'))
		throw new SyntaxError (ident, ["'Identifiant'"]);
	}
	
	return ident;
    }

    /**
       block := '{' instruction* '}'
       | instruction
    */
    private Block visitBlock () {
	auto par = _lex.next ();
	Array!Instruction insts;
	while (true) {
	    auto next = _lex.next ();
	    if (next == Keys.IF) insts.insertBack (visitIf ());
	    else if (next == Keys.WHILE) insts.insertBack (visitWhile ());
	    else if (next == Keys.CALL) insts.insertBack (visitCall ());
	    else if (next == Keys.SKIP) insts.insertBack (visitSkip ());
	    else if (next == Tokens.RPAR) break;
	    else {
		_lex.rewind ();
		insts.insertBack (visitExpressionUlt ());
	    }
	}
	return new Block (par, insts);
    }

    private Instruction visitInstruction () {
	return null;
    }

    /**
     expressionult := expression (_ultimeop expression)*
     */
    private Expression visitExpressionUlt () {
	auto left = visitVar ();
	auto tok = _lex.next ();
	if (tok != Tokens.AFFECT) throw new SyntaxError (tok, [Tokens.AFFECT.descr]);
	auto right = visitExpression ();
	auto next = _lex.next ();
	if (next != Tokens.SEMI_COLON) _lex.rewind ();
	return new Affect (tok, left, right);
    }    

    private Expression visitExpression () {
	auto left = visitHigh ();
	auto tok = _lex.next ();
	if (find!"b == a" (_expOp, tok) != []) {
	    auto right = visitHigh ();
	    return visitExpression (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }

    private Expression visitExpression (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_expOp, tok) != []) {
	    auto right = visitHigh ();
	    return visitExpression (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }
    
    private Expression visitHigh () {
    	auto left = visitPth ();
    	auto tok = _lex.next ();
    	if (find!"b == a" (_highOp, tok) != []) {
    	    auto right = visitPth ();
    	    return visitHigh (new Binary (tok, left, right));
    	} else _lex.rewind ();
    	return left;
    }

    private Expression visitHigh (Expression left) {
	auto tok = _lex.next ();
	if (find!"b == a" (_highOp, tok) != []) {
	    auto right = visitPth ();
	    return visitHigh (new Binary (tok, left, right));
	} else _lex.rewind ();
	return left;
    }
    
    private Expression visitPth () {
	auto tok = _lex.next ();
	if (tok == Tokens.LPAR) {
	    auto expr = visitExpression ();
	    tok = _lex.next ();
	    if (tok != Tokens.RPAR) throw new SyntaxError (tok, [Tokens.RPAR.descr]);
	    return expr;
	} else {
	    _lex.rewind ();
	    auto cst = visitConstante ();
	    if (cst is null) {
		return visitVar ();
	    } else return cst;
	}
    }

    private Expression visitConstante () {
	auto tok = _lex.next ();
	if (tok.isEof ()) throw new SyntaxError (tok);
	if (tok.str [0] >= '0'&& tok.str [0] <= '9')
	    return visitNumeric (tok);
	else if (tok == Keys.TRUE || tok == Keys.FALSE)
	    return new Bool (tok);
	else _lex.rewind ();
	return null;
    }

    private Expression visitNumeric (Word begin) {
	foreach (it ; 0 .. begin.str.length) {
	    if (begin.str [it] < '0' || begin.str [it] > '9') {
		throw new SyntaxError (begin);
	    }
	}
	return new Int (begin);
    }    
    
    private Instruction visitIf () {
	_lex.rewind ();
	auto id = _lex.next ();

	Expression expr = null;
	Block block_if = null;
	Else block_else = null;

	auto next = _lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	expr = visitExpression ();
	next = _lex.next ();
	if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	next = _lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	_lex.rewind ();
	block_if = visitBlock ();
	
	next = _lex.next ();
	if (next != Keys.ELSE) {
	    _lex.rewind ();
	} else {
	    block_else = visitElse ();
	}
	return new If (id, expr, block_if, block_else);
    }

    private Else visitElse () {
	_lex.rewind ();
	auto id = _lex.next ();
	auto next = _lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	_lex.rewind ();
	Block block = visitBlock ();
	return new Else (id, block);
    }    
    
    private Instruction visitSkip () {
	_lex.rewind ();
	return new Skip (_lex.next ());
    }

    private Instruction visitWhile () {
	_lex.rewind ();
	auto id = _lex.next ();
	
	Expression expr;
	Block block;
	
	auto next = _lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	expr = visitExpression ();
	next = _lex.next ();
	if (next != Tokens.RPAR) throw new SyntaxError (next, [Tokens.RPAR.descr]);
	next = _lex.next ();
	if (next != Keys.DO) throw new SyntaxError (next, [Keys.DO.descr]);
	next = _lex.next ();
	if (next != Tokens.LPAR) throw new SyntaxError (next, [Tokens.LPAR.descr]);
	_lex.rewind ();
	block = visitBlock ();

	return new While (id, expr, block);
    }
        
}
