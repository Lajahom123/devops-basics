ff:
	cd infra/foundation && terraform fmt -recursive

fv:
	cd infra/foundation && terraform validate

fp:
	cd infra/foundation && terraform plan

fa:
	cd infra/foundation && terraform apply


rf:
	cd infra/runtime && terraform fmt -recursive

rv:
	cd infra/runtime && terraform validate

rp:
	cd infra/runtime && terraform plan

ra:
	cd infra/runtime && terraform apply