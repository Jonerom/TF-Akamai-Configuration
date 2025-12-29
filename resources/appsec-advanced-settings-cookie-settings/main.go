package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"time"
	"github.com/akamai/AkamaiOPEN-edgegrid-golang/v7/pkg/edgegrid"
)

// ConfigVersionResponse represents the response structure when fetching config versions
type ConfigVersionResponse struct {
	ConfigID           int `json:"configId"`
	ConfigName         string `json:"configName"`
	LastCreatedVersion int    `json:"lastCreatedVersion"`
}

// CookieSettingsPayload represents the payload structure for this API
type CookieSettingsPayload struct {
	CookieDomain        string `json:"cookieDomain"`
	UseAllSecureTraffic bool   `json:"useAllSecureTraffic"`
}


var client *http.Client

func main() {
	// Arguments
	edgercPath := flag.String("edgerc", "~/.edgerc", "Path to .edgerc")
	section := flag.String("section", "default", "Section in .edgerc")
	configID := flag.String("config-id", "", "AppSec Config ID")
	inputSecure := flag.Bool("use-all-secure", true, "Enforce UseAllSecureTraffic")
	flag.Parse()
	// Validation
	if *configID == "" {
		log.Fatal("Error: -config-id is required")
	}
	// Authentication
	fullPath, err := expandPath(*edgercPath)
	if err != nil {
		log.Fatalf("Could not resolve edgerc path: %v", err)
	}
	conf, err := edgegrid.Init(fullPath, *section)
	if err != nil {
		log.Fatalf("Failed to load .edgerc credentials from %s (section: %s): %v", fullPath, *section, err)
	}
	client = &http.Client{}
	// Fetch latest configuration version
	fmt.Printf("Step 1: Fetching latest config version")
	latestVersion, err := getLatestVersion(conf, *configID)
	if err != nil {
		log.Fatalf("Failed to get version: %v", err)
	}
	// Set and PUT desired state into payload
	desiredState := CookieSettingsPayload{
		CookieDomain:        "automatic",
		UseAllSecureTraffic: *inputSecure,
	}
	fmt.Println("Step 2: Pushing Cookie Settings")
	err := updateCookieSettings(conf, *configID, latestVersion, desiredState)
	if err != nil {
		log.Fatalf("Update failed: %v", err)
	}
	// Verify by fetching back the settings and comparing
	fmt.Println("Step 3: Verifying remote state")
	// Retry logic time window
	retryInterval := 5 * time.Second
	timeoutDuration := 5 * time.Minute
	timeoutChan := time.After(timeoutDuration)
	ticker := time.NewTicker(retryInterval)
	defer ticker.Stop()
	startTime := time.Now()
	// Retry loop until timeout or success
	for {
		select {
		case <-timeoutChan:
			log.Fatal("TIMEOUT: Cookie settings did not stabilize after 5 minutes.")
		case <-ticker.C:
			elapsed := time.Since(startTime).Round(time.Second)
			fmt.Printf("Verifying state ... %s\n", elapsed)
			if verifyState(conf, *configID, latestVersion, desiredState) {
				return
			}
		}
	}
}

// Support Functions

// verifyState fetches and compares the desired and actual state, returning true if successful
func verifyState(conf edgegrid.Config, configID string, version int, desired CookieSettingsPayload) bool {
	actual, err := getCookieSettings(conf, configID, version)
	if err != nil {
		fmt.Printf("   -> Fetch failed: %v\n", err)
		return false
	}
	if reflect.DeepEqual(desired, actual) {
		fmt.Println("SUCCESS: Settings verified.")
		return true
	}
	return false
}


// getLatestVersion fetches the latest editable configuration version
func getLatestVersion(conf edgegrid.Config, configID string) (int, error) {
	path := fmt.Sprintf("/appsec/v1/configs/%s/versions", configID)
	respBody, err := sendRequest(conf, "GET", path, nil)
	if err != nil {
		return 0, err
	}
	var versionResp ConfigVersionResponse
	if err := json.Unmarshal(respBody, &versionResp); err != nil {
		return 0, fmt.Errorf("could not parse version response: %v", err)
	}
	return versionResp.LastCreatedVersion, nil
}

// updateCookieSettings performs the PUT request with the desired settings
func updateCookieSettings(conf edgegrid.Config, configID string, version int, payload CookieSettingsPayload) error {
	path := fmt.Sprintf("/appsec/v1/configs/%s/versions/%d/advanced-settings/cookie-settings", configID, version)
	jsonBytes, _ := json.Marshal(payload)
	_, err := sendRequest(conf, "PUT", path, jsonBytes)
	return err
}

// getCookieSettings performs the GET request to read the current settings
func getCookieSettings(conf edgegrid.Config, configID string, version int) (CookieSettingsPayload, error) {
	path := fmt.Sprintf("/appsec/v1/configs/%s/versions/%d/advanced-settings/cookie-settings", configID, version)
	respBody, err := sendRequest(conf, "GET", path, nil)
	if err != nil {
		return CookieSettingsPayload{}, err
	}
	var state CookieSettingsPayload
	if err := json.Unmarshal(respBody, &state); err != nil {
		return CookieSettingsPayload{}, err
	}
	return state, nil
}

// sendRequest is the generic request handler
func sendRequest(conf edgegrid.Config, method, path string, body []byte) ([]byte, error) {
	reqURL := url.URL{
		Scheme: "https",
		Host:   conf.Host,
		Path:   path,
	}
	var buf io.Reader
	if body != nil {
		buf = bytes.NewBuffer(body)
	}
	req, err := http.NewRequest(method, reqURL.String(), buf)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req = edgegrid.AddRequestHeader(conf, req)
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	respBytes, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("API Error %d: %s | Body: %s", resp.StatusCode, resp.Status, string(respBytes))
	}
	return respBytes, nil
}

// expandPath handles the "~" character in file paths
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
