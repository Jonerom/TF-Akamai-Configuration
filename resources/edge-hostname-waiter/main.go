package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
	"github.com/akamai/AkamaiOPEN-edgegrid-golang/v7/pkg/edgegrid"
)

// EdgeHostnamesResponse represents the response structure for edge hostnames
type EdgeHostnamesResponse struct {
	EdgeHostnames []struct {
		EdgeHostname            string `json:"edgeHostname"`
		SupportsZoneApexMapping bool   `json:"supportsZoneApexMapping"`
	} `json:"edgeHostnames"`
}

func main() {
	// Arguments
	edgercPath := flag.String("edgerc", "~/.edgerc", "Path to .edgerc file")
	section := flag.String("section", "default", "Section in .edgerc to use")
	targetHostname := flag.String("hostname", "", "The Edge Hostname to wait for")
	timeoutMinutes := flag.Int("timeout", 30, "Timeout in minutes")
	intervalSeconds := flag.Int("interval", 20, "Polling interval in seconds")
	flag.Parse()
	// Validation
	if *targetHostname == "" {
		log.Fatal("Error: -hostname argument is required")
	}
	// Authentication
	fullPath, err := expandPath(*edgercPath)
	if err != nil {
		log.Fatalf("Could not resolve edgerc path: %v", err)
	}
	conf, err := edgegrid.New(
		edgegrid.WithFile(fullPath),
		edgegrid.WithSection(*section),
	)
	if err != nil {
		log.Fatalf("Failed to load .edgerc credentials from %s (section: %s): %v", fullPath, *section, err)
	}
	// Polling loop
	fmt.Printf("Waiting for Edge Hostname '%s' to appear in the account\n", *targetHostname)
	fmt.Printf("Timeout: %dm | Interval: %ds\n", *timeoutMinutes, *intervalSeconds)
	// Retry logic time window
	timeoutDuration := time.Duration(*timeoutMinutes) * time.Minute
	tickerInterval := time.Duration(*intervalSeconds) * time.Second
	timeoutChan := time.After(timeoutDuration)
	ticker := time.NewTicker(tickerInterval)
	defer ticker.Stop()
	// Retry loop until timeout or success
	startTime := time.Now()
	for {
		select {
		case <-timeoutChan:
			log.Fatalf("TIMEOUT: Edge Hostname '%s' was not found after %d minutes.", *targetHostname, *timeoutMinutes)
		case <-ticker.C:
			elapsed := time.Since(startTime).Round(time.Second)
			fmt.Printf("Checking status ... (%s elapsed)\n", elapsed)
			if checkExists(conf, *targetHostname) {
				fmt.Printf("SUCCESS: Edge Hostname '%s' is created and visible.\n", *targetHostname)
				os.Exit(0)
			}
		}
	}
}

// Support Functions

// checkExists fetches the list and searches for the Edge Hostname target
func checkExists(conf *edgegrid.Config, target string) bool {
	reqURL := fmt.Sprintf("https://%s%s", conf.Host, "/config-dns/v2/data/edgehostnames")
	req, err := http.NewRequest(http.MethodGet, reqURL, nil)
	if err != nil {
		log.Printf("Error creating request: %v", err)
		return false
	}
	req.Header.Set("Accept", "application/json")
	conf.SignRequest(req)
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf(" Network error: %v", err)
		return false
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		return false
	}
	body, _ := io.ReadAll(resp.Body)
	var data EdgeHostnamesResponse
	if err := json.Unmarshal(body, &data); err != nil {
		log.Printf("Error parsing JSON: %v", err)
		return false
	}
	for _, eh := range data.EdgeHostnames {
		if eh.EdgeHostname == target {
			return true
		}
	}

	return false
}

func expandPath(path string) (string, error) {
	if strings.HasPrefix(path, "~/") {
		dirname, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		return filepath.Join(dirname, path[2:]), nil
	}
	return path, nil
}