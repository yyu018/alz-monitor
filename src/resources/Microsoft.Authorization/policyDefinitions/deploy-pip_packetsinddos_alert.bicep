// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

targetScope = 'managementGroup'

param policyLocation string = 'centralus'
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

@allowed([
    '0'
    '1'
    '2'
    '3'
    '4'
])
param parAlertSeverity string = '4'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
    'PT6H'
    'PT12H'
    'P1D'
])
param parWindowSize string = 'PT5M'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
])
param parEvaluationFrequency string = 'PT5M'

@allowed([
    'deployIfNotExists'
    'disabled'
])
param parPolicyEffect string = 'disabled'

param parAutoMitigate string = 'true'

param parAlertState string = 'true'

param parThreshold string = '40000'

param parMonitorDisable string = 'MonitorDisable' 

module PacketsInDDOSAlert '../../arm/Microsoft.Authorization/policyDefinitions/managementGroup/deploy.bicep' = {
    name: '${uniqueString(deployment().name)}-pippiddos-policyDefinitions'
    params: {
        name: 'Deploy_PublicIp_PacketsInDDoSAttack_Alert'
        displayName: '[DINE] Deploy PIP Packets in DDoS Attack Alert'
        description: 'DINE policy to audit/deploy PIP Packets in DDoS Attack Alert'
        location: policyLocation
        metadata: {
            version: '1.0.1'
            Category: 'Networking'
            source: 'https://github.com/Azure/ALZ-Monitor/'
            _deployed_by_alz_monitor: 'True'
        }
        parameters: {
            severity: {
                type: 'String'
                metadata: {
                    displayName: 'Severity'
                    description: 'Severity of the Alert'
                }
                allowedValues: [
                    '0'
                    '1'
                    '2'
                    '3'
                    '4'
                ]
                defaultValue: parAlertSeverity
            }
            windowSize: {
                type: 'String'
                metadata: {
                    displayName: 'Window Size'
                    description: 'Window size for the alert'
                }
                allowedValues: [
                    'PT1M'
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                    'PT6H'
                    'PT12H'
                    'P1D'
                ]
                defaultValue: parWindowSize
            }
            evaluationFrequency: {
                type: 'String'
                metadata: {
                    displayName: 'Evaluation Frequency'
                    description: 'Evaluation frequency for the alert'
                }
                allowedValues: [
                    'PT1M'
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                ]
                defaultValue: parEvaluationFrequency
            }
            autoMitigate: {
                type: 'String'
                metadata: {
                    displayName: 'Auto Mitigate'
                    description: 'Auto Mitigate for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAutoMitigate
            }
            enabled: {
                type: 'String'
                metadata: {
                    displayName: 'Alert State'
                    description: 'Alert state for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAlertState
            }
            threshold: {
                type: 'String'
                metadata: {
                    displayName: 'Threshold'
                    description: 'Threshold for the alert'
                }
                defaultValue: parThreshold
            }
            effect: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Effect of the policy'
                }
                allowedValues: [
                    'deployIfNotExists'
                    'disabled'
                ]
                defaultValue: parPolicyEffect
            }

            MonitorDisable: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Tag name to disable monitoring resource. Set to true if monitoring should be disabled'
                }
          
                defaultValue: parMonitorDisable
            }
        }
        policyRule: {
            if: {
                allOf: [
                    {
                        field: 'type'
                        equals: 'Microsoft.Network/publicIPAddresses'
                    }
                    {
                        field: '[concat(\'tags[\', parameters(\'MonitorDisable\'), \']\')]'
                        notEquals: 'true'
                    }
                ]
            }
            then: {
                effect: '[parameters(\'effect\')]'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/metricAlerts'
                    existenceCondition: {
                        allOf: [
                            {
                                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft-Azure-Monitor-SingleResourceMultipleMetricCriteria.allOf[*].metricNamespace'
                                equals: 'Microsoft.Network/publicIPAddresses'
                            }
                            {
                                field: 'Microsoft.Insights/metricAlerts/criteria.Microsoft-Azure-Monitor-SingleResourceMultipleMetricCriteria.allOf[*].metricName'
                                equals: 'PacketsInDDoS'
                            }
                            {
                                field: 'Microsoft.Insights/metricalerts/scopes[*]'
                                equals: '[concat(subscription().id, \'/resourceGroups/\', resourceGroup().name, \'/providers/Microsoft.Network/publicIPAddresses/\', field(\'fullName\'))]'
                            }
                            {
                                field: 'Microsoft.Insights/metricAlerts/enabled'
                                equals: '[parameters(\'enabled\')]'
                            }
                        ]
                    }
                    deployment: {
                        properties: {
                            mode: 'incremental'
                            template: {
                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                contentVersion: '1.0.0.0'
                                parameters: {
                                    resourceName: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'resourceName'
                                            description: 'Name of the resource'
                                        }
                                    }
                                    resourceId: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'resourceId'
                                            description: 'Resource ID of the resource emitting the metric that will be used for the comparison'
                                        }
                                    }
                                    severity: {
                                        type: 'String'
                                    }
                                    windowSize: {
                                        type: 'String'
                                    }
                                    evaluationFrequency: {
                                        type: 'String'
                                    }
                                    autoMitigate: {
                                        type: 'String'
                                    }
                                    enabled: {
                                        type: 'String'
                                    }
                                    threshold: {
                                        type: 'String'
                                    }
                                }
                                variables: {}
                                resources: [
                                    {
                                        type: 'Microsoft.Insights/metricAlerts'
                                        apiVersion: '2018-03-01'
                                        name: '[concat(parameters(\'resourceName\'), \'-PacketsInDDosAlert\')]'
                                        location: 'global'
                                        tags: {
                                            _deployed_by_alz_monitor: true
                                        }
                                        properties: {
                                            description: 'Metric Alert for Public IP Address Packets IN DDOS'
                                            severity: '[parameters(\'severity\')]'
                                            enabled: '[parameters(\'enabled\')]'
                                            scopes: [
                                                '[parameters(\'resourceId\')]'
                                            ]
                                            evaluationFrequency: '[parameters(\'evaluationFrequency\')]'
                                            windowSize: '[parameters(\'windowSize\')]'
                                            criteria: {
                                                allOf: [
                                                    {
                                                        name: 'PacketsInDDoS'
                                                        metricNamespace: 'Microsoft.Network/publicIPAddresses'
                                                        metricName: 'PacketsInDDoS'
                                                        operator: 'GreaterThanOrEqual'
                                                        threshold: '[parameters(\'threshold\')]'
                                                        timeAggregation: 'Total'
                                                        criterionType: 'StaticThresholdCriterion'
                                                    }
                                                ]
                                                'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
                                            }
                                            autoMitigate: '[parameters(\'autoMitigate\')]'
                                            parameters: {
                                                severity: {
                                                    value: '[parameters(\'severity\')]'
                                                }
                                                windowSize: {
                                                    value: '[parameters(\'windowSize\')]'
                                                }
                                                evaluationFrequency: {
                                                    value: '[parameters(\'evaluationFrequency\')]'
                                                }
                                                autoMitigate: {
                                                    value: '[parameters(\'autoMitigate\')]'
                                                }
                                                enabled: {
                                                    value: '[parameters(\'enabled\')]'
                                                }
                                                threshold: {
                                                    value: '[parameters(\'threshold\')]'
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            parameters: {
                                resourceName: {
                                    value: '[field(\'name\')]'
                                }
                                resourceId: {
                                    value: '[field(\'id\')]'
                                }
                                severity: {
                                    value: '[parameters(\'severity\')]'
                                }
                                windowSize: {
                                    value: '[parameters(\'windowSize\')]'
                                }
                                evaluationFrequency: {
                                    value: '[parameters(\'evaluationFrequency\')]'
                                }
                                autoMitigate: {
                                    value: '[parameters(\'autoMitigate\')]'
                                }
                                enabled: {
                                    value: '[parameters(\'enabled\')]'
                                }
                                threshold: {
                                    value: '[parameters(\'threshold\')]'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
