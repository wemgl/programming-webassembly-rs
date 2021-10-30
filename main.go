package main

import (
	"io/ioutil"
	"net/http"
)

func index(w http.ResponseWriter, r *http.Request) {
	body, _ := ioutil.ReadFile("./index.html")
	w.Write(body)
}

func checkersTest(w http.ResponseWriter, r *http.Request) {
	body, _ := ioutil.ReadFile("./checkers_test.html")
	w.Write(body)
}

func checkers(w http.ResponseWriter, r *http.Request) {
	body, _ := ioutil.ReadFile("./checkers.html")
	w.Write(body)
}

func main() {
	http.HandleFunc("/checkersTest", checkersTest)
	http.HandleFunc("/checkers", checkers)
	http.HandleFunc("/", index)
	http.Handle("/wasm/", http.StripPrefix("/wasm/", http.FileServer(http.Dir("wasm"))))
	http.ListenAndServe(":8080", nil)
}
