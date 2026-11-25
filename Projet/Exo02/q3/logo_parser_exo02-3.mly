%{
open Logo_ast_exo01_1
%}

%token <int> NBR
%token <string> ID
%token FORWARD BACKWARD RIGHT LEFT PENUP PENDOWN CLEAR
%token DEUX_POINTS POINT_VIRGULE POINT CROCHET_OUV CROCHET_FER PARE_OUV PARE_FER
%token PLUS MOINS MULT DIV MOD
%token DEF REPEAT

%start main 
%type <Logo_ast_exo01_1.t_expr> expr_atom
%type <Logo_ast_exo01_1.t_expr> expr_mult
%type <Logo_ast_exo01_1.t_expr> expr_plus
%type <Logo_ast_exo01_1.t_cmd> cmd
%type <Logo_ast_exo01_1.t_instr> instr_simple
%type <Logo_ast_exo01_1.t_instr> instr
%type <Logo_ast_exo01_1.t_instr> instr_seq
%type <Logo_ast_exo01_1.t_instr> main

%%
expr_atom : 
  | NBR { Cst($1) }
  | DEUX_POINTS ID { Var($2) }
  | MOINS expr_atom { Neg($2) }
  | PARE_OUV expr_plus PARE_FER { $2 }
;

expr_mult :
  | expr_atom { $1 }
  | expr_mult MULT expr_atom { Opbin(Mult,$1,$3) }
  | expr_mult DIV expr_atom { Opbin(Div,$1,$3) }
  | expr_mult MOD expr_atom { Opbin(Mod,$1,$3) }
;

expr_plus :
  | expr_mult { $1 }
  | expr_plus PLUS expr_mult { Opbin(Plus,$1,$3) }
  | expr_plus MOINS expr_mult { Opbin(Moins,$1,$3) }
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

