
all:
	@echo running make all
	go generate
	go run first.go lexer.go

test : 
	@echo running make test
	@go run lexer.go t_lexer.go

.PHONY : all test