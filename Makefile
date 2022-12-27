TF := terraform -chdir="$(CURDIR)/infra"

ANSIBLE_INVENTORY_FILE := $(CURDIR)/inventory

.PHONY: infra-started
infra-started:
	$(TF) apply

$(ANSIBLE_INVENTORY_FILE): infra-started
	$(TF) output -raw ansible_inventory > $@

.PHONY: setup-k0s
setup-k0s: $(ANSIBLE_INVENTORY_FILE)
	ansible-playbook -i $< site.yml
