# Codecov Setup Instructions

This document provides step-by-step instructions for repository maintainers to activate the code coverage system.

## Prerequisites

The code coverage system has been fully implemented in this repository. To activate it, you need to:

## Step 1: Create Codecov Account

1. Go to [https://codecov.io](https://codecov.io)
2. Sign in with your GitHub account
3. Authorize Codecov to access your repositories

## Step 2: Add Repository to Codecov

1. In Codecov dashboard, click "Add Repository"
2. Find and select `Mosquito-Alert/Mosquito-Alert-Mobile-App`
3. Follow the setup wizard

## Step 3: Get Codecov Token

1. In the repository settings on Codecov, find the "Repository Upload Token"
2. Copy the token (it looks like: `a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6`)

## Step 4: Add Token to GitHub Secrets

1. Go to your GitHub repository: `Mosquito-Alert/Mosquito-Alert-Mobile-App`
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Name: `CODECOV_TOKEN`
5. Value: Paste the token from Step 3
6. Click **Add secret**

## Step 5: Verify Setup

1. Create a new pull request or push to the main branch
2. Check that the GitHub Actions workflow completes successfully
3. Verify that coverage data appears in Codecov dashboard
4. Confirm that the badge in README.md shows the actual coverage percentage

## Expected Results

Once setup is complete:

- ✅ Coverage badge in README.md will show live coverage percentage
- ✅ Pull requests will include coverage reports in comments
- ✅ Coverage trends will be tracked over time
- ✅ Detailed coverage reports available at Codecov dashboard

## Troubleshooting

### Badge Shows "unknown"
- Ensure `CODECOV_TOKEN` is correctly set in GitHub secrets
- Verify that at least one workflow has run successfully
- Check that the workflow includes the coverage upload step

### No Coverage Data in Codecov
- Confirm that tests are actually running (`flutter test --coverage`)
- Check that `coverage/lcov.info` file is being generated
- Verify workflow logs for any upload errors

### Coverage Percentage Seems Wrong
- Review `codecov.yml` configuration for excluded files
- Ensure all relevant source files are being tested
- Check that generated files are properly excluded

## Configuration Files

The following files configure the coverage system:

- `.github/workflows/analyze_and_test.yml` - CI workflow with coverage
- `codecov.yml` - Codecov configuration
- `docs/COVERAGE.md` - Developer documentation

## Support

If you encounter issues:

1. Check the GitHub Actions logs for error messages
2. Review Codecov documentation: https://docs.codecov.io
3. Contact the development team for assistance

## Security Note

The `CODECOV_TOKEN` is sensitive information that should only be accessible to repository maintainers. Do not share it publicly or commit it to the repository.