package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

var url string

func init() {
	var nginxHost = os.Getenv("NGINX_HOST")
	if nginxHost == "" {
		nginxHost = "localhost"
	}
	url = "http://" + nginxHost + "/citylots.json"
}

type Cities struct {
	Features []struct {
		Properties struct {
			FROM_ST string `json:"FROM_ST"`
		} `json:"properties"`
	} `json:"features"`
}

func requestData(ch chan<- *Cities) {
	res, err := http.Get(url)
	if err != nil {
		log.Fatal(err)
	}
	var data Cities
	json.NewDecoder(res.Body).Decode(&data)

	ch <- &data
}

func extractData(data *Cities) {
	res := map[string]int{}
	for _, f := range data.Features {
		res[f.Properties.FROM_ST]++
	}
	fmt.Printf("Some data %d\n", len(res))
}

func main() {
	start := time.Now()
	var x [200]int

	ch := make(chan *Cities)
	for _ = range x {
		go requestData(ch)
	}

	for _ = range x {
		extractData(<-ch)
	}
	fmt.Printf("Time spent: %.2fs\n", time.Since(start).Seconds())
}
