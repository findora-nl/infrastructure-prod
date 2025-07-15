#!/bin/bash
find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -exec terraform fmt {} +