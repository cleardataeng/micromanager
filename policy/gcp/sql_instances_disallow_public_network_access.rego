# Copyright 2019 The resource-policy-evaluation-library Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package rpe.policy.sql_instances_disallow_public_network_access

#####
# Policy metadata
#####

description = "Disallow public network access to SQL instances"

applies_to = ["sqladmin.googleapis.com/Instance"]

#####
# Resource metadata
#####

resource = input.resource

labels = resource.settings.userLabels

#####
# Policy evaluation
#####

default compliant = true

default excluded = false

compliant = false {
	resource.settings.ipConfiguration.authorizedNetworks[_].value == "0.0.0.0/0"
}

excluded {
	data.exclusions.label_exclude(labels)
}

#####
# Remediation
#####

remediate = {
	"_remediation_spec": "v2beta1",
	"steps": [remove_bad_acls],
}

remove_bad_acls = {
	"method": "patch",
	"params": {
		"project": resource.project,
		"instance": resource.name,
		"body": {"settings": {"ipConfiguration": {"authorizedNetworks": _compliant_authorized_networks}}},
	},
}

# Remove any noncompliant authorized networks
_compliant_authorized_networks = [net |
	net := resource.settings.ipConfiguration.authorizedNetworks[_]
	net.value != "0.0.0.0/0"
]
