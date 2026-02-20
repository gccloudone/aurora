---
title: "GitHub Actions for Creating Releases"
linkTitle: "GitHub Actions for Creating Releases"
weight: 5
aliases: ["/team/sop/gha-create-release"]
date: 2026-02-13
draft: false
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

This document is designed for the GitHub Action repository to help other developers implement release automation in their repositories.

## Context

This GitHub Composite Action simplifies and standardizes the process of creating GitHub releases. It ensures consistent release naming, tagging and notes generation across all repositories.

## Setup

The composite action lives in the (dot).github repository. There are 2 separate actions , one for checking PR labels and other for creating the releases. Both work in conjunction to simplify and automate the release creation process.

The create-release action gets triggered when a PR is opened and has appropriate label applied. The check-pr-labels action gets triggered to verify the label applied. MAJOR, MINOR, PATCH and SKIP are the valid labels to create a major release version or minor release version or patch release version or skip the release respectively.

# Authentication

The action automatically uses the built-in GITHUB_TOKEN and permissions are assigned within the workflow.

# Usage

To use this action, create a workflow file (e.g., .github/workflows/trigger_release.yml) in your repository and reference this action. 

   ```sh
name: Check Label and Trigger Release
run-name: "PR #${{ github.event.pull_request.number }} [${{ github.event.action }}]: ${{ github.event.pull_request.title }}"

on:
  pull_request:
    types: [opened, reopened, synchronize , labeled, unlabeled, closed]
    branches:
      - main

permissions:
  contents: write

jobs:
  publish_release:
    name: Check Label and Trigger Release
    runs-on: ubuntu-latest
    steps:
      - name: Use Composite Check PR Labels Action
        id: label
        uses: gccloudone-aurora-iac/.github/.github/actions/check-pr-labels@main

      - name: Use Composite Create Release Action
        if: github.event.pull_request.merged == true 
        uses: gccloudone-aurora-iac/.github/.github/actions/create-release@main
        with:
          release_type: ${{ steps.label.outputs.release_type }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          release_branch: "main"

   ```




