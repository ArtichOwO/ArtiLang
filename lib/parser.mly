%{
  open Ast
%}

%token SEMICOLON
%token COMMA
%token EOF

%token <string> MACRO

%token LPAREN RPAREN
%token LBRACE RBRACE

%token FOR
%token IF ELSE

%token EQ NEQ
%token NEAR FAR INT

%token GLOBAL

%token <string> STRING
%token <string> LABEL
%token <int> INTEGER

%start <program> program

%%

program: e=defs*; EOF { e }

defs:
    | is_global=option(GLOBAL);ftype=function_type;fname=label;LPAREN;args=argument*;RPAREN;
      LBRACE;stmt_list=stmt*;RBRACE 
        { FuncDef { is_global; ftype; fname; args; stmt_list } }
    | m=MACRO { MacroDef m }

function_type:
    | NEAR { Near }

argument: lbl=label;option(COMMA) { lbl }

label: lbl=LABEL { lbl }

stmt:
    | IF;i=expr;LBRACE;t=stmt*;RBRACE { If (i,t) }
    | m=MACRO { MacroStmt m }

expr:
    | LPAREN;lv=value;EQ;rv=value;RPAREN { Eq (lv,rv) }
    | v=value { Value v }
    | LPAREN;v=value;RPAREN { Value v }
    | v=label { Variable v }
    | LPAREN;v=label;RPAREN { Variable v }

value:
    | i=INTEGER { Integer i }
