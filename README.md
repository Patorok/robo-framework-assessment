# Robot Framework Assessment

## Overview

This project requires a Python virtual environment to manage its dependencies. Follow the instructions below to set up your environment.

## Prerequisites

Make sure you have Python installed on your machine. You can download it from [python.org](https://www.python.org/downloads/).

## Setting Up the Virtual Environment

```bash
# Create a virtual environment named 'env'
python3 -m venv env
or
python -m venv env

# Activate the virtual environment
# On Windows (Command Prompt)
.\env\Scripts\activate

# On Windows (PowerShell)
.\env\Scripts\Activate.ps1

# On macOS and Linux
source env/bin/activate

# Install the required packages
pip install -r requirements.txt

# To deactivate the virtual environment
deactivate
