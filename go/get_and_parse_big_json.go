package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"math"
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

func Round(f float64) float64 {
	return math.Floor(f + .5)
}

func requestData() io.Reader {
	res, err := http.Get(url)
	if err != nil {
		log.Fatal(err)
	}
	return res.Body
}

func parseResponse(res io.Reader) *Cities {
	var data Cities
	json.NewDecoder(res).Decode(&data)
	return &data
}

func extractData(data *Cities) {
	res := map[string]int{}
	for _, f := range data.Features {
		res[f.Properties.FROM_ST]++
	}
	fmt.Printf("Some data %d\n", len(res))
}

type TimeSample struct {
	Request float64 `json:"request"`
	Parse   float64 `json:"parse"`
	Process float64 `json:"process"`
	Total   float64 `json:"total"`
}

func (ts TimeSample) Round() TimeSample {
	return TimeSample{
		Request: Round(ts.Request),
		Parse:   Round(ts.Parse),
		Process: Round(ts.Process),
		Total:   Round(ts.Total),
	}
}

func main() {
	start := time.Now()
	var x [200]int
	timings := make(chan TimeSample)

	for _ = range x {
		go func() {
			t := TimeSample{}

			s := time.Now()
			response := requestData()
			t.Request = time.Since(s).Seconds()

			s = time.Now()
			data := parseResponse(response)
			t.Parse = time.Since(s).Seconds()

			s = time.Now()
			extractData(data)
			t.Process = time.Since(s).Seconds()

			timings <- t
		}()
	}

	totalTimings := TimeSample{}
	for _ = range x {
		t := <-timings
		totalTimings.Request += t.Request
		totalTimings.Parse += t.Parse
		totalTimings.Process += t.Process
	}

	totalTimings.Total = time.Since(start).Seconds()
	totalTimings.Request /= float64(len(x))
	totalTimings.Parse /= float64(len(x))
	totalTimings.Process /= float64(len(x))

	fmt.Printf("Time spent: %.2fs request, %.2fs parse, %.2fs process, %.2fs total\n",
		totalTimings.Request, totalTimings.Parse, totalTimings.Process, totalTimings.Total)

	results, err := json.Marshal(totalTimings.Round())
	if err != nil {
		log.Fatal(err)
	}

	pwd, _ := os.Getwd()
	err = ioutil.WriteFile(pwd+"/results.json", results, 0644)
	if err != nil {
		log.Fatal(err)
	}
}
