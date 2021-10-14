package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestOutputs(t *testing.T) {
	t.Parallel()

	uniqueId := random.UniqueId()
	repoName := fmt.Sprintf("test-%s", uniqueId)
	orgName := os.Getenv("GITHUB_OWNER")

	expectedDefaultBranch := "main"
	expectedFullName := orgName + "/" + repoName
	expectedName := repoName
	expectedUrl := "https://github.com/" + orgName + "/" + repoName

	// Copy the terraform folder to a temp folder
	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "..", ".")

	// Set Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name": repoName,
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables.
	outputDefaultBranch := terraform.Output(t, terraformOptions, "default_branch")
	outputFullName := terraform.Output(t, terraformOptions, "full_name")
	outputName := terraform.Output(t, terraformOptions, "name")
	outputUrl := terraform.Output(t, terraformOptions, "ui_url")

	// Check the output variables have the expected values
	assert.Equal(t, expectedDefaultBranch, outputDefaultBranch)
	assert.Equal(t, expectedFullName, outputFullName)
	assert.Equal(t, expectedName, outputName)
	assert.Equal(t, expectedUrl, outputUrl)
}
