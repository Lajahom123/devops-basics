ff:
	cd infra/platform && terraform fmt -recursive

fv:
	cd infra/platform && terraform validate

fp:
	cd infra/platform && terraform plan

fa:
	cd infra/platform && terraform apply


rf:
	cd infra/runtime && terraform fmt -recursive

rv:
	cd infra/runtime && terraform validate

rp:
	cd infra/runtime && terraform plan

ra:
	cd infra/runtime && terraform apply