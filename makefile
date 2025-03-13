.PHONY: test-all test-docker test-terraform test-helm build deploy build-deploy

build:
	@echo "🚀 Building Docker image..."
	@docker build -t romulofranca/hello-app:latest .

deploy:
	@echo "📦 Deploying application with Terraform..."
	@cd terraform && terraform init && terraform apply -auto-approve
	@$(MAKE) -s show-url

build-deploy: build deploy
	@echo "🔧 Build and deploy steps completed."

destroy:
	@echo "🗑️ Destroying application with Terraform..."
	@cd terraform && terraform destroy -auto-approve

test-docker:
	@echo "🐳 Running Docker & Rails app tests..."
	@./test_docker.sh

test-terraform:
	@echo "🛠️  Running Terraform tests..."
	@cd terraform && terraform init -backend=false && terraform validate && terraform plan -out=tfplan && rm tfplan

test-helm:
	@echo "🧰 Running Helm lint..."
	@helm lint helm

test-all:
	@echo "🏁 Running all tests..." && \
	docker_log=$$(mktemp) && \
	echo "🐳 Running Docker tests..." && \
	./test_docker.sh > $$docker_log 2>&1 ; docker_status=$$? ; \
	if [ $$docker_status -eq 0 ]; then docker_result="✅ Passed"; else docker_result="❌ Failed"; fi && \
	terraform_log=$$(mktemp) && \
	echo "🛠️  Running Terraform tests..." && \
	(cd terraform && terraform init -backend=false && terraform validate && terraform plan -out=tfplan && rm tfplan) > $$terraform_log 2>&1 ; terraform_status=$$? ; \
	if [ $$terraform_status -eq 0 ]; then terraform_result="✅ Passed"; else terraform_result="❌ Failed"; fi && \
	helm_log=$$(mktemp) && \
	echo "🧰 Running Helm tests..." && \
	helm lint helm > $$helm_log 2>&1 ; helm_status=$$? ; \
	if [ $$helm_status -eq 0 ]; then helm_result="✅ Passed"; else helm_result="❌ Failed"; fi && \
	echo "-----------------------------------" && \
	printf "%-15s %-15s\n" "Test" "Status" && \
	printf "%-15s %-15s\n" "----------------" "---------------" && \
	printf "%-15s %-15s\n" "Docker" "$$docker_result" && \
	printf "%-15s %-15s\n" "Terraform" "$$terraform_result" && \
	printf "%-15s %-15s\n" "Helm" "$$helm_result" && \
	echo "-----------------------------------" && \
	if [ $$docker_status -ne 0 ]; then echo "🐳 Docker logs:"; cat $$docker_log; fi && \
	if [ $$terraform_status -ne 0 ]; then echo "🛠️  Terraform logs:"; cat $$terraform_log; fi && \
	if [ $$helm_status -ne 0 ]; then echo "🧰 Helm logs:"; cat $$helm_log; fi && \
	rm -f $$docker_log $$terraform_log $$helm_log && \
	if [ $$docker_status -ne 0 ] || [ $$terraform_status -ne 0 ] || [ $$helm_status -ne 0 ]; then exit 1; fi

show-url:
	@echo "⏳ Waiting a few seconds for the service to become ready..."
	@sleep 5
	@NODE_PORT=$$(kubectl get svc hello-app -o jsonpath='{.spec.ports[0].nodePort}'); \
	echo "🚀 Your application is available at: http://localhost:$$NODE_PORT"