PYTHON = python3
VENV = .venv
CRED_ENV_FILE=creds.env
TEMPLATE_REPO=https://github.com/KorneevRV/DS_template

# Load variables from credentials environment file, if it exists
ifneq ("$(wildcard $(CRED_ENV_FILE))","")
include $(CRED_ENV_FILE)
export $(shell awk -F= '{print $$1}' $(CRED_ENV_FILE))
endif

# creating virtual environment
venv:
	$(PYTHON) -m venv $(VENV)
	@echo "Virtual environment created in '$(VENV)'"

# installing packages
install: venv
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
	@echo "Dependencies installed in the virtual environment"

# Copies template files from the source repository to the specified directory.
template:
	@echo "Cloning template repository next to the existing project directory..."
	@git clone $(TEMPLATE_REPO)
	@git checkout -b template
	@rsync -av --no-times --no-owner --no-group --no-perms --exclude '.git' --exclude 'README.md' DS_template/ .
	@git add .
	@echo "Cleaning up temporary files..."
	@rm -rf DS_template/
	@echo "Repository updated successfully with template files"

# Edits the credentials in the credentials environment file.
addcreds:
	@echo "Editing credentials in $(CRED_ENV_FILE)..."
	@for var in "MINIO_URL:MinIO URL" \
				"MINIO_BUCKET_NAME:MinIO bucket name" \
				"MINIO_ACCESS_KEY:MinIO access key" \
				"MINIO_SECRET_KEY:MinIO secret key"; do \
		key=$$(echo $$var | cut -d':' -f1); \
		desc=$$(echo $$var | cut -d':' -f2); \
		current_value=$$(grep "^$$key=" $(CRED_ENV_FILE) | cut -d'=' -f2 || echo ""); \
		echo "Current $$desc: $$current_value"; \
		printf "Enter new $$desc (leave empty to keep current): "; \
		read value; \
		if [ -n "$$value" ]; then \
			if grep -q "^$$key=" $(CRED_ENV_FILE); then \
				sed -i "s/^$$key=.*/$$key=$$value/" $(CRED_ENV_FILE); \
				echo "Updated $$key in $(CRED_ENV_FILE)"; \
			else \
				echo "$$key=$$value" >> $(CRED_ENV_FILE); \
				echo "Added $$key to $(CRED_ENV_FILE)"; \
			fi; \
		else \
			echo "Kept current $$key"; \
		fi; \
	done

# Initialize DVC in the specified directory.
# Then adds the S3 bucket to the DVC repository.
adddvc:
	git branch dvc && \
	git checkout dvc && \
	. $(VENV)/bin/activate && \
	dvc init && \
	dvc remote add -d my_s3_bucket s3://$(MINIO_BUCKET_NAME) && \
	dvc remote modify my_s3_bucket use_ssl false && \
	dvc remote modify my_s3_bucket endpointurl $(MINIO_URL) && \
	dvc remote modify --local my_s3_bucket access_key_id $(MINIO_ACCESS_KEY) && \
	dvc remote modify --local my_s3_bucket secret_access_key $(MINIO_SECRET_KEY) && \
	git add .dvc/config && \
	dvc add data && \
	git add data.dvc && \
	echo 'S3 bucket successfully connected, DVC initialized.' && \
	echo 'We recommend running the following commands to create the first data tracking record:' && \
	echo '  dvc commit' && \
	echo '  git commit'