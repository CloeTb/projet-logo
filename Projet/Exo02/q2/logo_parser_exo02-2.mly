%{
open Logo_ast
%}

%token <int> NBR
%token <string> ID
%token FORWARD BACKWARD RIGHT LEFT PENUP PENDOWN CLEAR 
%token DEUX_POINTS POINT_VIRGULE POINT CROCHET_OUV CROCHET_FER 
%token DEF REPEAT

%start main 
%type <Logo_ast.t_expr> expr
%type <Logo_ast.t_cmd> cmd
%type <Logo_ast.t_instr> instr_simple
%type <Logo_ast.t_instr> instr
%type <Logo_ast.t_instr> instr_seq
%type <Logo_ast.t_instr> main

%%
expr : 
  | NBR { Cst($1) }
  | DEUX_POINTS ID { Var($2) }
;

cmd : 
  | FORWARD expr_plus { Forward($2) }
  | BACKWARD expr_plus { Backward($2) }
  | RIGHT expr_plus { Right($2) }
  | LEFT expr_plus { Left($2) }
  | PENUP { PenUp }
  | PENDOWN { PenDown }
  | CLEAR { Clear }
;

instr_simple:
  | DEF ID expr_plus { Define($2,$3) }
  | cmd { Cmd($1) }
;

instr :
  | instr_simple { $1 }
  | REPEAT expr_plus CROCHET_OUV instr_seq CROCHET_FER { Repeat($2,$4) }
;

instr_seq :
  | instr { $1 }
  | instr_seq POINT_VIRGULE instr { Seq($1,$3) }
;

main :
  | instr_seq POINT { $1 }
;

