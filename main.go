package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

func main() {
	url := "http://179.254.169.254/latest/dynamic/instance-identity/document"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		panic(err)
	}

	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	var data map[string]interface{}
	err = json.Unmarshal(body, &data)
	if err != nil {
		panic(err)
	}

	// Pretty print the JSON and write it to a file
	jsonStr, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		panic(err)
	}

	err = ioutil.WriteFile("metadata.json", jsonStr, 0644)
	if err != nil {
		panic(err)
	}

	fmt.Println(string(jsonStr))
}
