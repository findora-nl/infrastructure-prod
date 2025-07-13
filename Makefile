VENV_DIR := .venv

.PHONY: venv install pre-commit

venv:
	@echo "🔧 Creating virtual environment in $(VENV_DIR)..."
	python3 -m venv $(VENV_DIR)

install: venv
	@echo "📦 Installing Python dependencies..."
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install -r requirements.txt

pre-commit: install
	@echo "🔍 Setting up pre-commit hooks..."
	$(VENV_DIR)/bin/pre-commit install
	