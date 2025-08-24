.PHONY: lint package
lint:
	helm lint charts/wazuh
package:
	helm package charts/wazuh
