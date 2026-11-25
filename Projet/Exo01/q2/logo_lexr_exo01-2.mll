rule read_lexeme = parse
  | [' ' '\t' '\n' '\r']    { read_lexeme lexbuf } (*s'il y a  un espace on ignore et on boucle*)
  
  | "Def"     { print_endline "Def"; read_lexeme lexbuf }
  | "Avance"  { print_endline "Avance"; read_lexeme lexbuf }
  | "Recule"  { print_endline "Recule"; read_lexeme lexbuf }
  | "Gauche"  { print_endline "Gauche"; read_lexeme lexbuf }
  | "Droite"  { print_endline "Droite"; read_lexeme lexbuf }
  | "Efface"  { print_endline "Efface"; read_lexeme lexbuf }
  | "Dessine" { print_endline "Dessine"; read_lexeme lexbuf }
  | "Deplace" { print_endline "Deplace"; read_lexeme lexbuf }

  | "."       { print_endline "Point"; read_lexeme lexbuf }
  | ":"       { print_endline "Deux-points"; read_lexeme lexbuf }
  
  | ('+' | '-')? ['0'-'9']+ as entier { print_endline ("Entier: " ^ entier); read_lexeme lexbuf }
  | ['a'-'z' '_'] (['a'-'z' 'A'-'Z'] | ['0'-'9'] | '_')* as variable { print_endline ("Variable: " ^ variable); read_lexeme lexbuf }
  
  | eof       { print_endline "Fin du fichier" }
  | _         { print_endline "Caractère non reconnu"; read_lexeme lexbuf }