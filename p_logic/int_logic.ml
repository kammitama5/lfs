open Common

open Common_logic

(* INT logic (syntax = <,>, [x..y],  sugar for <=, >= *)

type interval = Val of int | Sup of int | Inf of int | In of (int * int)

let parse = fun s -> 
  match s with
  | s when s =~ "^[0-9]+$"  -> Val (s_to_i s)
  | s when s =~ "^>\\([0-9]+\\)$" -> Sup (s_to_i (matched1 s))
  | s when s =~ "^<\\([0-9]+\\)$" -> Inf (s_to_i (matched1 s))
  | s when s =~ "^\\[\\([0-9]+\\)\\.\\.\\([0-9]+\\)\\]$" -> 
      let (x1, x2) = matched2 s +> pair s_to_i in
      let _ = assert(x1 < x2) in
      In (x1, x2)
  (* sugar *)
  | s when s =~ "^>=\\([0-9]+\\)$" -> Sup (s_to_i (matched1 s) - 1)
  | s when s =~ "^<=\\([0-9]+\\)$" -> Inf (s_to_i (matched1 s) + 1)
  | _ -> failwith "parsing error on interval"
(* note pour <= et >= aimerait ptet via |, mais peut pas :( => decaler l'entier :)  
   mais ptet certains sugar  neederait ca => comment faire ? peut faire des trucs via axiomes, mais bon 
*)


let (interval_logic: logic) = fun (Prop s1) (Prop s2) -> 
  let (x1, x2) = (parse s1, parse s2) in
  (match (x1, x2) with
  | (Val x, Val y) -> x = y                           (* 2 |= 2 *)
  | (Val x, Sup y) -> x > y                            (* 2 |= >1 *)
  | (Val x, Inf y) -> x < y                            (* 2 |= <3 *)
  | (Val x, In (y, z)) -> x <= z && x >= y             (* 2 |= [0..3] *)
  | (Sup x, Sup y) -> x >= y                           (* >3 |= >2 *)
  | (Inf x, Inf y) -> x <= y                           (* <2 |= <3 *)
  | (In (x1,y1), In (x2, y2)) -> x1 >= x2 && y1 <= y2  (* [2..3] |= [0..4] *)
  | (In (x,y), Sup z) -> x > z                         (* [1..4] |= >0 *)
  | (In (x,y), Inf z) -> y < z                         (* [1..4] |= <5 *)
  | _ -> false
   )

let is_formula_int (Prop s) = match parse s with (Val _) -> false | _ -> true

let (main: unit) = interact_logic interval_logic     is_formula_int
