{
  open Parser

  let buf = Buffer.create 64
}

let newline = '\n' | "\r\n"
let whitespace = [' ' '\t']
let dec_digit = ['0'-'9']
let hex_digit = ['0'-'9' 'a'-'f' 'A'-'F']
let id_char = ['0'-'9' 'a'-'z' 'A'-'Z' '_']

rule translate = parse
  | eof { EOF }
  | "/*" _* "*/" { translate lexbuf }
  | "//" [^ '\r' '\n']* (newline) { Lexing.new_line lexbuf; translate lexbuf }
  | newline { Lexing.new_line lexbuf; translate lexbuf }
  | ',' { COMMA }
  | ';' { SEMICOLON }
  | ':' { COLON }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | '=' { ASSIGN }
  | '[' { LBRACK }
  | ']' { RBRACK }
  | '*' { ASTERISK }
  | '"' { read_string lexbuf }
  | "for" { FOR }
  | "while" { WHILE }
  | "until" { UNTIL }
  | "if" { IF }
  | "else" { ELSE }
  | "near" { NEAR }
  | "far" { FAR }
  | "int" { INT }
  | "global" { GLOBAL }
  | "extern" { EXTERN }
  | "byte" { BYTE }
  | "word" { WORD }
  | "let" { LET }
  | "==" { EQ }
  | "!=" { NEQ }
  | dec_digit+ as i { INTEGER (int_of_string i) }
  | "0x" hex_digit+ as i { INTEGER (int_of_string i) }
  | id_char+ as str { LABEL str }
  | whitespace { translate lexbuf }
  | _ as c { raise @@ Exceptions.Invalid_character c }

and read_string = parse
  | '"' { let c = Buffer.contents buf in
          Buffer.clear buf; STRING c }
  | "\\x" { Buffer.add_char buf @@ get_int_value lexbuf; read_string lexbuf }
  | '\\' { Buffer.add_char buf @@ special_char lexbuf; read_string lexbuf }
  | [^ '"'] { Buffer.add_string buf (Lexing.lexeme lexbuf); read_string lexbuf }
  | eof { raise Exceptions.String_never_terminated }
  | _ as c { raise @@ Exceptions.Invalid_character c }

and special_char = parse
  | '"' { '"' }
  | '\\' { '\\' }
  | 'n' { '\n' }
  | 'r' { '\r' } 
  | 'b' { '\b' }
  | 't' { '\t' }
  | '0' { '\x00' }
  | _ as c { raise @@ Exceptions.Invalid_character c }

and get_int_value = parse
  | hex_digit hex_digit as i { Printf.sprintf "0x%s" i |> int_of_string |> Char.chr }
  | _ { raise @@ Exceptions.Invalid_character (get_next_char lexbuf) }

and get_next_char = parse _ as c { c }
