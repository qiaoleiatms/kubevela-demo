"monitoring": {
    annotations: {}
    attributes: {
        appliesToWorkloads: []
        conflictsWith: []
        podDisruptive: false
        workloadRefPath: ""
    }
    description: "My ingress route trait."
    labels: {}
    type: "trait"
}

template: {
    parameter: {
        type: string
        monitoringSettingsSecret: string
    }

    // +patchStrategy=retainKeys
	patch: {
		spec: template: spec: {

            // +patchKey=name
            containers: [{
                name: context.name
                
                // +patchKey=name
                volumeMounts: [
                    {
                        mountPath: "/app-insights/agents/settings"
                        name: "monitoringsettings-default-vol"
                    },
                    {
                        mountPath: "/app-insights/agents"
                        name: "app-insights-agents-vol"
                        readOnly: true
                    }
                ]
            }]
            
            // +patchKey=name
            volumes: [
                {
                    name: "monitoringsettings-default-vol"
                    secret: {
                        optional: true
                        secretName: parameter.monitoringSettingsSecret
                    }
                },
                {
                    emptyDir: medium: "Memory"
                    name: "app-insights-agents-vol"
                }
            ]

            // +patchKey=name
            initContainers: [{
                name: "ai"
                if parameter.type == "ApplicationInsights" {
                    image: "mcr.microsoft.com/azurespringapps/apm/applicationinsights:3.4.18-1.0.02521.1209-33689-2023-11-27"
                }
                imagePullPolicy: "IfNotPresent"
                command: ["sh", "-c", "/azure-spring-apps/apm/setup.sh"]
                volumeMounts: [
                    {
                        mountPath: "/app-insights/agents/settings"
                        name: "monitoringsettings-default-vol"
                    },
                    {
                        mountPath: "/app-insights/agents",
                        name: "app-insights-agents-vol"
                    }
                ]
            }]
        }
    }
}