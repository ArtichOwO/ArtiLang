type program = defs list

and defs =
  | FuncDef of {
      is_global : bool;
      ftype : function_type;
      fname : string;
      args : string list;
      stmt_list : stmt list;
      locals : string list;
    }
  | StaticVarUninitialized of {
      is_global : bool;
      stype : size_type;
      sname : string;
    }
  | StaticVar of {
      is_global : bool;
      stype : size_type;
      sname : string;
      value : static_value;
    }
  | Extern of string list

and label = string

and stmt =
  | If of expr * stmt list
  | IfElse of expr * stmt list * stmt list
  | For of stmt option * expr option * stmt option * stmt list
  | WhileUntil of expr option * bool * stmt list
  | LocalVar of string * value
  | Assignment of address_value * expr * size_type
  | SubAssignment of address_value * offset_value * expr * size_type
  | FuncCall of address_value * expr list

and expr = Value of value | N_Eq of bool * value * value

and function_type = Near

and size_type = Byte | Word

and value =
  | Integer of int
  | Variable of string
  | Subscript of address_value * offset_value
  | String of string

and offset_value = IntegerOffset of int | VariableOffset of string

and address_value =
  | IntegerAddress of int * int
  | VariableAddress of string
  | ComposedAddress of address_operand * address_operand

and address_operand = IntegerAddressOp of int | VariableAddressOp of string

and static_value = StaticInteger of int | StaticString of string

and arguments = string * int
