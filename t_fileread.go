package main

import "fmt"
import "io/ioutil"
import "bufio"
import "log"
import "os"

func hoge()(int, int){
	return 1,1
}


func main() {

	body, err := ioutil.ReadFile("./first.sample.code")
	if err != nil{
		log.Fatalf("error loading file(%s)\n", err.Error())
	}

	fmt.Printf("%v",string(body))
	fmt.Println("------------")
	f, err := os.Open("./first.sample.code")
	if err != nil {
		log.Fatalf("error : %s\n", err.Error())
	}

	defer f.Close()

	lines := make([]string, 0, 100)
	scanner := bufio.NewScanner(f)
	for scanner.Scan(){
		lines = append(lines, scanner.Text())
	}

	for i,line := range lines {
		fmt.Printf("%d:%s\n", i, line)
	}

}