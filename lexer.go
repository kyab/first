//go:generate go tool yacc -o first.go first.go.y

package main

import (
	"fmt"
	"text/scanner"
	"strings"
	"strconv"
)


func tokenIdString(id int) string {
	switch id {
	case PUTS:
		return "PUTS"
	case NUMBER:
		return "NUMBER"
	case NAME:
		return "NAME"
	case GO:
		return "GO"
	case GOR:
		return "GOR"
	case SLEEP:
		return "SLEEP"
	case STRING:
		return "STRING"
	default:
		return "OTHER(" + strconv.Itoa(id) + ")"
	}
}

type Statement interface {}

type VarDefStatement struct {
	name string
	//val	 int
	value Value
}

type PutsByNameStatement struct {
	name string
	lineno int
}

type PutsByValueStatement struct{
	value Value
	lineno int
}

type GoStatement struct {
	command string
	n int
	lineno int
}

type SleepStatement struct {
	val int
	lineno int
}

type BlockStatement struct {
	stmts []Statement
}

type GoBlockStatement struct {
	block BlockStatement
}

type Value interface{}
type IntValue int
type StringValue string


type Token struct {
	tokenId int 			//is this required??
	literal string
	lineno int
}

type MyLexer struct {
	s *scanner.Scanner
	statements []Statement
	lineno int
}

func (l *MyLexer) Lex(lval *yySymType) int {
	r := l.s.Scan()
	if r == scanner.EOF {
		return 0
	}
	if r == '\n' {
		r = l.s.Scan()
	}

	switch r {
	case scanner.Int:
		lval.token.tokenId = NUMBER
		lval.token.literal = l.s.TokenText()
	case scanner.String:
		lval.token.tokenId = STRING
		str_lit := l.s.TokenText()
		str := str_lit[1:len(str_lit)-1]
		lval.token.literal = str
	case scanner.Ident:
		switch l.s.TokenText() {
		case "puts":
			lval.token.tokenId = PUTS
		case "go":
			lval.token.tokenId = GO
		case "gor":
			lval.token.tokenId = GOR
		case "sleep":
			lval.token.tokenId = SLEEP
		default:
			lval.token.tokenId = NAME
		}
		lval.token.literal = l.s.TokenText()
	default:
		lval.token.tokenId = int(r)
		lval.token.literal = l.s.TokenText()
	}
	
	lval.token.lineno = l.s.Pos().Line
	l.lineno = lval.token.lineno

	fmt.Printf("in Lex(), type:%-10s, literal:%s\n", tokenIdString(lval.token.tokenId), lval.token.literal)
	return lval.token.tokenId
}

func (l *MyLexer) Error(e string) {
	fmt.Printf("error:%s line:%d\n", e, l.lineno)
}

func (l *MyLexer) Reduced(rule, state int, lval *yySymType) (stop bool) {
	fmt.Printf("Reduced rule=%d, state=%d, lval=%#v\n", rule, state, lval)
	return false
}


func (l *MyLexer) Init(src string) {
	l.s = new(scanner.Scanner)
	l.s.Init(strings.NewReader(src))
	//l.s.Whitespace = 1 << '\t' | 1 << ' ' | 1 << '\r'
}

