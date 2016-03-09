package main

import (
	"fmt"
	"os"
	"io/ioutil"
)

func main() {
	body, err := ioutil.ReadFile("./first.sample.code")
	if err != nil {
		fmt.Printf("error:%s\n", err.Error())
		os.Exit(1)
	}

	lexer := new(MyLexer)
	lexer.Init(string(body))

	token := new(Token)
	for true {
		tokenId := lexer.Lex(token)
		if tokenId == 0 {
			break
		}
		
	}


}