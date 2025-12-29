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

// SettingsPayload represents the payload structure for bot management settings
type SettingsPayload struct {
	EnableBotManagement                  bool `json:"enableBotManagement"`
	AddAkamaiBotHeader                   bool `json:"addAkamaiBotHeader"`
	ThirdPartyProxyServiceInUse          bool `json:"thirdPartyProxyServiceInUse"`
	RemoveBotManagementCookies           bool `json:"removeBotManagementCookies"`
	EnableActiveDetections               bool `json:"enableActiveDetections"`
	EnableBrowserValidation              bool `json:"enableBrowserValidation"`
	IncludeTransactionalEndpointRequests bool `json:"includeTransactionalEndpointRequests"`
	IncludeTransactionalEndpointStatus   bool `json:"includeTransactionalEndpointStatus"`
}

var client *http.Client

func main() {
	// Arguments
	edgercPath := flag.String("edgerc", "~/.edgerc", "Path to .edgerc file")
	section := flag.String("section", "default", "Section in .edgerc to use")
	configID := flag.String("config-id", "", "Config ID")
	policyID := flag.String("security-policy-id", "", "Security Policy ID")
	jsonPayloadArg := flag.String("payload", "", "Raw JSON payload string")
	flag.Parse()
	// Validation
	if *configID == "" || *jsonPayloadArg == "" {
		log.Fatal("Missing required arguments: config-id or payload")
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
	fmt.Printf("Latest Version Found: %d\n", latestVersion)
	// Set and PUT desired state from JSON payload
	var desiredState SettingsPayload
	if err := json.Unmarshal([]byte(*jsonPayloadArg), &desiredState); err != nil {
		log.Fatalf("Error parsing desired state: %v", err)
	}
	fmt.Println("Step 2: Pushing new botman configuration")
	err = updateSettings(conf, *configID, latestVersion, *policyID, desiredState)
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
			log.Fatal("TIMEOUT: Configuration state does not match after 5 minutes.")
		case <-ticker.C:
			elapsed := time.Since(startTime).Round(time.Second)
			fmt.Printf("Verifying state ... %s\n", elapsed)
			if verifyState(conf, *configID, latestVersion, *policyID, desiredState) {
				return
			}
		}
	}
}

// Support Functions

// verifyState fetches and compares the desired and actual state, returning true if successful
func verifyState(conf edgegrid.Config, configID string, version int, policyID string, desired SettingsPayload) bool {
	actualState, err := getSettings(conf, configID, version, policyID)
	if err != nil {
		fmt.Printf("Fetch failed: %v\n", err)
		return false
	}
	if reflect.DeepEqual(desired, actualState) {
		fmt.Println("SUCCESS: Configuration verified and matches desired state.")
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

// updateSettings performs the PUT request with the desired settings
func updateSettings(conf edgegrid.Config, configID string, version int, policyID string, payload SettingsPayload) error {
	path := fmt.Sprintf("/appsec/v1/configs/%s/versions/%d/security-policies/%s/bot-management-settings",
		configID, version, policyID)
	jsonBytes, _ := json.Marshal(payload)
	_, err := sendRequest(conf, "PUT", path, jsonBytes)
	return err
}

// getSettings performs the GET request to read the current settings
func getSettings(conf edgegrid.Config, configID string, version int, policyID string) (SettingsPayload, error) {
	path := fmt.Sprintf("/appsec/v1/configs/%s/versions/%d/security-policies/%s/bot-management-settings",
		configID, version, policyID)
	respBody, err := sendRequest(conf, "GET", path, nil)
	if err != nil {
		return SettingsPayload{}, err
	}
	var state SettingsPayload
	if err := json.Unmarshal(respBody, &state); err != nil {
		return SettingsPayload{}, err
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
