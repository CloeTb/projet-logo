(***************************************)
(*                                     *)
(*  Syntaxe abstraite pour un langage  *)
(*  "à la Logo"                        *)
(*                                     *)
(***************************************)

open Env ;;

open Turtle ;;
(* Decommenter si tortue graphique *)
(*
open Turtle_graphic
;;
*)

(*--------------------------------------------*)
(* type pour représenter l'état de la mémoire *)
(* La mémoire est l'ensemble des liaisons     *)
(* (variable, valeur) et une tartue           *)
(*--------------------------------------------*)
type t_state =
  Env.t_env * Turtle.t_turtle
;;

(*---------------------------------------------*)
(* types pour représenter la syntaxe abstraite *)
(* du langage                                  *)
(*---------------------------------------------*)

(*--------------------------------------------------------------*)
(* Le type pour la syntaxe abstraite des expressions            *)
(* Pour le moment, il n'y a que les constantes et les variables *)
(*--------------------------------------------------------------*)

type op_bin = Plus | Moins | Mult | Div | Mod
;;

type t_expr =
  | Cst of int
  | Var of t_ident
  | Neg of t_expr
  | Opbin of op_bin * t_expr * t_expr
;;

(*--------------------------------------------------------------*)
(* Le type pour la syntaxe abstraite des commandes de la tortue *)
(*--------------------------------------------------------------*)
type t_cmd =
  | Forward of t_expr
  | Backward of t_expr
  | Right of t_expr
  | Left of t_expr
  | PenUp
  | PenDown
  | Clear
;;

type t_opcmp = 
  | Egal 
  | Sup
  | Inf
;;

type t_bexpr =
  | Cmp of t_opcmp * t_expr * t_expr
;;

(*-------------------------------------------------------------------*)
(* Le type pour la syntaxe abstraite des instructions du langage     *)
(* Pour le moment, il y a la définition de la valeur d'une variable, *)
(* une commande pour la tartue et une suite d'instructions           *)
(*-------------------------------------------------------------------*)
type t_instr =
  | Define of t_ident * t_expr
  | Cmd of t_cmd
  | Seq of t_instr * t_instr
  | Repeat of t_expr * t_instr
  | Si of t_bexpr * t_instr * t_instr 
;;

(*------------------------------------------------------------------------*)
(* Fonctions d'interprétation                                             *)
(*------------------------------------------------------------------------*)


(*------------------------------------------------*)
(* Interprétation d'une expression                *)
(*   @param env : environnement qui contient les  *)
(*                valeurs des variables           *)
(*   @param e   : l'expression à interpéter       *)
(*                                                *)
(*   @return    : valeur de l'expression          *)
(*------------------------------------------------*)
let rec interp_expr (env : t_env) (e : t_expr) : int =
  match e with
  | Cst n -> n
  | Var v -> Env.value_of v env
  | Neg nb -> -(interp_expr env nb) 
  | Opbin (op, e1, e2) ->
    begin
      let n1 = interp_expr env e1
      and n2 = interp_expr env e2
      in
      match op with
      | Plus -> n1 + n2
      | Moins -> n1 - n2
      | Mult -> n1 * n2
      | Div -> n1 / n2
      | Mod -> n1 mod n2
    end
;;

(*-----------------------------------------------------*)
(* Interprétation d'une commande                       *)
(*   @param c   : la commande à interpéter             *)
(*   @param s   : un état composé d'un environnement   *) 
(*                et de la tortue courante             *)
(*                                                     *)
(*   @return    : la nouvelle tortue après l'exécution *)
(*                de la commande                       *)
(*-----------------------------------------------------*)
let interp_cmd (c : t_cmd) (s : t_state) : t_turtle =
  let (env, turtle) = s in (*On sépare l'environnement et la tortue comme t_state est un tuple*)
  match c with 
  | Forward e -> Turtle.move_fwd turtle (interp_expr env e) (*la distance à parcourir s'obtient si on interprète l'espression*)
  | Backward e -> Turtle.move_bck turtle (interp_expr env e)
  | Left e -> Turtle.turn_left turtle (interp_expr env e)
  | Right e -> Turtle.turn_right turtle (interp_expr env e)
  | PenUp -> Turtle.nodraw turtle
  | PenDown -> Turtle.draw turtle
  | Clear -> Turtle.reset()
;;

let rec iterate n f a =
  if n < 0 then failwith "compose : le nombre d'itération doit être positif"
  else if n > 0
  then iterate ( n - 1) f ( f a )
  else a
;;

(*-----------------------------------------------------*)
(* Interprétation d'une instruction                    *)
(*   @param c   : l'instruction à interpéter           *)
(*   @param s   : un état composé d'un environnement   *) 
(*                et de la tortue courante             *)
(*                                                     *)
(*   @return    : le nouvel état après l'exécution     *)
(*                de l'instruction                     *)
(*-----------------------------------------------------*)

let interp_bexpr (env : t_env) (bexpr : t_bexpr) : bool = 
  match bexpr with
  | Cmp(Egal, expr1, expr2) -> (interp_expr env expr1) = (interp_expr env expr2)
  | Cmp(Sup, expr1, expr2) -> (interp_expr env expr1) > (interp_expr env expr2)
  | Cmp(Inf, expr1, expr2) -> (interp_expr env expr1) < (interp_expr env expr2)
;; 

let rec interp_instr (i : t_instr) (s : t_state) : t_state =
  let (env, turtle) = s in
  match i with 
  | Define (ident, expr) -> (Env.add_binding env ident (interp_expr env expr),turtle) (*la tortue ne change pas, mais l'environnement si, alors on l'update*)
  | Cmd cmd -> (env, interp_cmd cmd s) (*on met à jour la tortue*)
  | Seq (instr1, instr2) -> interp_instr instr2 (interp_instr instr1 s) (*on fait la seconde instruction en partant du nouvel état après la première*)
  | Repeat (nbtour,instr1) -> iterate (interp_expr env nbtour) (interp_instr instr1) s
  | Si (bexpr, instr1, instr2) ->
      if interp_bexpr env bexpr then
        interp_instr instr1 s
      else
        interp_instr instr2 s
;;
