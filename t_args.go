package main

import "fmt"
import "os"

func main() {
	fmt.Printf("arg count = %d\n", len(os.Args))
	for _, arg := range os.Args[0:] {
		fmt.Println(arg)
	}
 
}