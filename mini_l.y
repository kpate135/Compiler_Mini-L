%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char *msg);
    extern int currLine;
    extern int currPos;
    FILE * yyin;
%}

%union{
int num_val;
char* id_val;
}
%error-verbose
%start prog_start
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE FOR WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <id_val> IDENT
%token <num_val> NUMBER
%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

%%
prog_start:     functions {printf("prog_start -> functions\n");}
        ;

functions:      /*empty*/ {printf("functions -> epsilon\n");}
        | function functions {printf("functions -> function functions\n");}
        ;

function:       FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
        ;

declarations:       /*empty*/ {printf("declarations -> epsilon\n");}
        | declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
        ;

declaration:        identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
        ;

identifiers:        ident {printf("identifiers -> ident\n");}
        | ident COMMA identifiers {printf("identifiers -> IDENT COMMA identifiers\n");}
        ;

ident:      IDENT {printf("ident -> IDENT %s\n", $1);}
        ;

statements:     statement SEMICOLON {printf("statements -> statement SEMICOLON\n");}
        | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
        ;

statement:      var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
        | IF bool_exp THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF\n");}
        | IF bool_exp THEN statements ELSE statements ENDIF {printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n");}
        | WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n");}
        | DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
        | READ var vars {printf("statement -> READ var vars\n");}
        | WRITE var vars {printf("statement -> WRITE var vars\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        | RETURN expression {printf("statement -> RETURN expression\n");}
        ;

vars:       /*empty*/ {printf("vars -> epsilon\n");}  
        | COMMA var vars {printf("vars -> COMMA var vars\n");}
        ;

bool_exp:       relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
        | relation_and_exp OR bool_exp {printf("bool_exp -> relation_and_exp OR bool_exp\n");}
        ;

relation_and_exp:       relation_exp {printf("relation_and_exp -> relation_exp\n");}
        | relation_exp AND relation_and_exp {printf("relation_and_exp -> relation_exp AND relation_and_exp\n");}
        ;

relation_exp:       expression comp expression {printf("relation_exp -> expression comp expression\n");}
        | NOT expression comp expression {printf("relation_exp -> NOT expression comp expression\n");}
        | TRUE {printf("relation_exp -> TRUE\n");}
        | NOT TRUE {printf("relation_exp -> NOT TRUE\n");}
        | FALSE {printf("relation_exp -> FALSE\n");}
        | NOT FALSE {printf("relation_exp -> NOT FALSE\n");}
        | L_PAREN bool_exp R_PAREN {printf("relation_exp -> L_PAREN bool_exp R_PAREN\n");}
        | NOT L_PAREN bool_exp R_PAREN {printf("relation_exp -> NOT L_PAREN bool_exp R_PAREN\n");}
        ;

comp:       EQ {printf("comp -> EQ\n");}
        | NEQ {printf("comp -> NEQ\n");}
        | LT {printf("comp -> LT\n");}
        | GT {printf("comp -> GT\n");}
        | LTE {printf("comp -> LTE\n");}
        | GTE {printf("comp -> GTE\n");}
        ;

expression:     multiplicative_expr {printf("expression -> multiplicative_expr\n");}
        | multiplicative_expr ADD expression {printf("expression -> multiplicative_expr ADD expression\n");}
        | multiplicative_expr SUB expression {printf("expression -> multiplicative_expr SUB expression\n");}
        ;

multiplicative_expr:        term {printf("multiplicative_expr -> term\n");}
        | term MULT multiplicative_expr {printf("multiplicative_expr -> term MULT multiplicative_expr\n");}
        | term DIV multiplicative_expr {printf("multiplicative_expr -> term DIV multiplicative_expr\n");}
        | term MOD multiplicative_expr {printf("multiplicative_expr -> term MOD multiplicative_expr\n");}
        ;

term:       term_a {printf("term -> term_a\n");}
        | term_b {printf("term -> term_b\n");}
        ;

term_a:     var {printf("term_a -> var\n");}
        | SUB var {printf("term_a -> SUB var\n");}
        | NUMBER {printf("term_a -> NUMBER\n");}
        | SUB NUMBER {printf("term_a -> SUB NUMBER\n");}
        | L_PAREN expression R_PAREN {printf("term_a -> L_PAREN expression R_PAREN\n");}
        | SUB L_PAREN expression R_PAREN {printf("term_a -> SUB L_PAREN expression R_PAREN\n");}
        ;

term_b:     ident L_PAREN expr R_PAREN {printf("term_b -> IDENT L_PAREN expr R_PAREN\n");}
        ;

expr:       expression {printf("expr -> expression\n");}
        | expression COMMA expr {printf("expr -> expression COMMA expr\n");}
        | /*empty*/ {printf("expr -> epsilon\n");} 
        ;

var:        ident {printf("term_b -> IDENT\n");}  
        | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("term_b -> IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
        ;
%%

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL)
        {
            printf("This is not a valid file name: %s filename\n", argv[1]);
            exit(0);
        }
    }
    yyparse();
    return 0;
}

void yyerror(const char *msg)
{
    printf("Error at line %d and position %d: %s\n", currLine, currPos, msg);
    exit(0);
}