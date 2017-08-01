package main

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"
)

type TestProfile struct {
	Number               int     `json:"number"`
	InputFile            string  `json:"inputFile"`
	NumberOfJobs         int     `json:"numberOfJobs"`
	ExpectedNumberOfKeys int     `json:"expectedNumberOfKeys"`
	Tech                 string  `json:"tech"`
	TotalTime            float64 `json:"totalTime"`
}

func LoadTestProfile() TestProfile {
	raw, err := ioutil.ReadFile("./test-profile.json")
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}

	var p TestProfile
	json.Unmarshal(raw, &p)
	return p
}

var url string
var testProfile TestProfile

func init() {
	var nginxHost = os.Getenv("NGINX_HOST")
	if nginxHost == "" {
		nginxHost = "localhost"
	}
	testProfile = LoadTestProfile()
	testProfile.Tech = "go"
	url = "http://" + nginxHost + "/" + testProfile.InputFile
}

type Cities struct {
	Features []struct {
		Properties struct {
			FROM_ST string `json:"FROM_ST"`
		} `json:"properties"`
	} `json:"features"`
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
	if len(res) != testProfile.ExpectedNumberOfKeys {
		log.Fatal(fmt.Sprintf("Expected %v to equal %v", len(res), testProfile.ExpectedNumberOfKeys))
	}
}

func main() {
	start := time.Now()
	var x = make([]int, testProfile.NumberOfJobs)
	done := make(chan bool)

	fmt.Println("Running...")

	for _ = range x {
		go func() {
			response := requestData()
			data := parseResponse(response)
			extractData(data)
			done <- true
		}()
	}

	for _ = range x {
		<-done
	}

	testProfile.TotalTime = time.Since(start).Seconds()

	fmt.Printf("Time spent: %.2fs\n", testProfile.TotalTime)

	results, err := json.Marshal(testProfile)
	if err != nil {
		log.Fatal(err)
	}

	pwd, _ := os.Getwd()
	err = ioutil.WriteFile(fmt.Sprintf("%s/results/go-%v.json", pwd, testProfile.Number), results, 0644)
	if err != nil {
		log.Fatal(err)
	}
}
