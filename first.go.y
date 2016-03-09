%{
package main

import (
	"fmt"
	"os"
	"strconv"
	"io/ioutil"
	"time"
	// "runtime"
)

%}


%union{
	statements []Statement
	statement  Statement
	value 	   Value
	token Token
}

%type<statements> statements
%type<statements> program
%type<statement> goroutine
%type<statement> block
%type<statement> statement
%type<value>	value

%token<token>  NAME NUMBER PUTS GO SLEEP STRING GOR

%%

program : 
	statements {
		fmt.Printf("<program>\n")
		if l,ok := yylex.(*MyLexer); ok {
			l.statements = $$
		}
	}


statements
	: 
	{
		fmt.Printf("<statements with zero>\n")
		$$ = nil
		if l, ok := yylex.(*MyLexer); ok {
			l.statements = $$
		}
	}
	// | statement statements
	// {
	// 	$$ = append([]Statement{$1}, $2...)
	// 	if l, ok := yylex.(*MyLexer); ok {
	// 		l.statements = $$
	// 	}
	// }
	| statements statement
	{
		fmt.Printf("<statements statement>\n")
		$$ = append($1, $2)
		// if l,ok := yylex.(*MyLexer); ok {
		// 	l.statements = $$
		// }
	}
	| statements block
	{
		fmt.Printf("<statements block>\n")
		$$ = append($1, $2)
	}

statement
	: PUTS NAME
	{
		fmt.Printf("PUTS NAME\n")
		$$ = PutsByNameStatement{name : $2.literal, lineno : $1.lineno}
	}
	| PUTS value
	{
		fmt.Printf("PUTS value\n")
		$$ = PutsByValueStatement{value : $2, lineno : $1.lineno}
	}
	// | NAME '=' NUMBER
	// {
	// 	fmt.Printf("NAME = NUMBER\n")
	// 	intval, _ := strconv.Atoi($3.literal)
	// 	//$$ = VarDefStatement{name : $1.literal, val:val}
	// 	$$ = VarDefStatement{name : $1.literal, value:IntValue(intval)}
	// } 
	// | NAME '=' STRING
	// {
	// 	fmt.Printf("NAME = STRING\n")
	// 	$$ =VarDefStatement{name : $1.literal, value:StringValue($3.literal)}
	// }
	| NAME '=' value
	{
		fmt.Printf("NAME = value\n")
		$$ = VarDefStatement{name : $1.literal, value:$3}
	} 
	| GO NAME NUMBER
	{
		fmt.Printf("GO NAME NUMBER\n")
		val, _ := strconv.Atoi($3.literal)
		$$ = GoStatement{command : $2.literal, n:val, lineno : $1.lineno}
	}
	| SLEEP NUMBER
	{
		fmt.Printf("SLEEP NUMBER\n")
		val, _ := strconv.Atoi($2.literal)
		$$ = SleepStatement{val : val, lineno : $1.lineno}
	}
	| goroutine{
		$$ = $1
	}

value
	: NUMBER
	{
		fmt.Printf("NUMBER")
		intval, _ := strconv.Atoi($1.literal)
		$$ = IntValue(intval)
	}
	| STRING
	{
		fmt.Printf("STRING")
		$$ = StringValue($1.literal)
	}


goroutine
	: GOR block
	{
		fmt.Printf("goroutine!\n")
		if b, ok := $2.(BlockStatement); ok {
			$$ = GoBlockStatement{block : b}
		}
	}

block 
	: '{' statements '}'
	{
		fmt.Printf("block!\n")
		$$ = BlockStatement{stmts : $2}
	}

// expression
// 	: expression '+' expression {
// 		$$ = AddExpression{$1, $2}
// 	}
// 	| primitive_expression {

// 	}

// primitive_expression
// 	: NAME {

// 	}
// 	| NUMBER {

// 	}
// 	| STRING {

// 	}

%%

var(
	// variables = map[string]int{}
)

func evaluate(statements []Statement, nest int) bool {
	fmt.Printf("-----evaluate-----(nest %d)\n",nest) 

	variables := map[string]Value{}

	for _, stmt := range statements {
		switch s := stmt.(type){
		case VarDefStatement:
			variables[s.name] = s.value
		case PutsByNameStatement:
			val, ok := variables[s.name]
			if ok {
				fmt.Printf("> %v\n", val)
			}else{
				fmt.Printf("> runtime error : unknown variable:\"%s\" in line:%d\n", s.name, s.lineno)
				
				return false
			}
		case PutsByValueStatement:
			fmt.Printf("> %v\n", s.value)
		case GoStatement:
			fmt.Printf("> go %s started\n", s.command)

			var message = ""
			switch s.command {
			case "printfoo":
				message = "foo"
			case "printbar":
				message = "bar"
			}
			go func() {
				for i := 0 ; i < s.n ; i++ {
					fmt.Printf("from goroutine : %s(%d)\n", message, i)
					time.Sleep(10*time.Millisecond)
				}
			}()

		case SleepStatement:
			// fmt.Printf("> sleeping...\n")
			time.Sleep(time.Duration(s.val) * time.Millisecond)
			// fmt.Printf("> wake up\n")

		case BlockStatement:
			fmt.Printf("block evaluating\n")
			ok := evaluate(s.stmts, nest+1)
			if !ok {
				return false
			}
		case GoBlockStatement:
			fmt.Printf("goroutine evaluating\n")
			go evaluate(s.block.stmts, -1)
			// ok := evaluate(s.block.stmts, -1)
			// if !ok {
			// 	return false
			// }

		}
	}
	fmt.Printf("-----evaluate-----(nest %d) done\n",nest) 

	return true
	// for k, v := range variables {
	// 	fmt.Printf("k = %s, v = %d\n",k, v)
	// }
}


func main() {
	body, err := ioutil.ReadFile("./first.sample.code")
	if err != nil {
		fmt.Printf("error:%s\n", err.Error())
		os.Exit(1)
	}

	lexer := new(MyLexer)
	lexer.Init(string(body))

	ret := yyParse(lexer)
	if ret == 0 {
		//fmt.Printf("%#v\n", lexer.statements)
		for _, stmt := range lexer.statements {
			fmt.Printf("%#v\n", stmt)
		}
		evaluate(lexer.statements, 0)
	}


}

