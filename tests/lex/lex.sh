#!/bin/bash

echo "--------- LEXICAL ANALYSIS TESTS ---------"
echo ""
regular_test () {
  test_name=$1
  echo "---- ${test_name^^} ----" 

  expression=$2 
  echo "expression: $expression"

  expected=$3

  result=$(echo "$expression" | ./lex)

  if [[ "$result" == "$expected" ]]; then
    echo "PASSED"
  else
    echo "FAILED"
    echo "Expected: $expected"
    echo "Got: $result"
  fi
  echo ""
}

test_reserved_words () {
  name="reserved words"
  exp="int float if else while return"
  expected=$"1 TK_PR_INT [int]
1 TK_PR_FLOAT [float]
1 TK_PR_IF [if]
1 TK_PR_ELSE [else]
1 TK_PR_WHILE [while]
1 TK_PR_RETURN [return]"  

  regular_test "$name" "$exp" "$expected"
}

test_special_characters () {
  name="special characters"
  exp="-!*/%+-<>{}()=,;"
  expected="1 TK_ESPECIAL [-]
1 TK_ESPECIAL [!]
1 TK_ESPECIAL [*]
1 TK_ESPECIAL [/]
1 TK_ESPECIAL [%]
1 TK_ESPECIAL [+]
1 TK_ESPECIAL [-]
1 TK_ESPECIAL [<]
1 TK_ESPECIAL [>]
1 TK_ESPECIAL [{]
1 TK_ESPECIAL [}]
1 TK_ESPECIAL [(]
1 TK_ESPECIAL [)]
1 TK_ESPECIAL [=]
1 TK_ESPECIAL [,]
1 TK_ESPECIAL [;]"
  regular_test "$name" "$exp" "$expected"
}

test_compose_operators () {
  name="compose operators"
  exp="<= >= == != & |"
  expected="1 TK_OC_LE [<=]
1 TK_OC_GE [>=]
1 TK_OC_EQ [==]
1 TK_OC_NE [!=]
1 TK_OC_AND [&]
1 TK_OC_OR [|]"
  
  regular_test "$name" "$exp" "$expected"
}

test_reserved_words
test_compose_operators
test_special_characters
