{
open Logo_parser_exo01_3
exception Not_recognized
exception Quit
}

rule read_lexeme = parse
  | [' ' '\t' '\n' '\r']    { read_lexeme lexbuf } (*s'il y a  un espace on ignore et on boucle*)
  
  | "--" [^ '\n']* '\n' { read_lexeme lexbuf }
  | "Repete"  { REPEAT }
  | "Def"     { DEF }
  | "Avance"  { FORWARD }
  | "Recule"  { BACKWARD }
  | "Gauche"  { LEFT }
  | "Droite"  { RIGHT }
  | "Efface"  { CLEAR }
  | "Dessine" { PENDOWN }
  | "Deplace" { PENUP }
  | "Si"      { IF }
  | "Alors"   { THEN }
  | "Sinon"   { ELSE }
  | "FinSi"   { ENDIF }

  | "("       { PARE_OUV }
  | ")"       { PARE_FER }
  | "["       { CROCHET_OUV }
  | "]"       { CROCHET_FER }
  | "."       { POINT }
  | ":"       { DEUX_POINTS }
  | ";"       { POINT_VIRGULE }
  
  | ['0'-'9']+ as entier { NBR (int_of_string entier) }
  | ['a'-'z' '_'] (['a'-'z' 'A'-'Z'] | ['0'-'9'] | '_')* as variable { ID variable }

  | "+"       { PLUS }
  | "-"       { MOINS }
  | "*"       { MULT }
  | "/"       { DIV }
  | "%"       { MOD }
  | "="       { EGAL }
  | ">"       { SUP }
  | "<"       { INF }

  | "#Fin"    { print_string ("La commande #Fin, on s'arrête") ;
                print_newline() ;
                raise Quit 
              }
  | _         { raise Not_recognized }