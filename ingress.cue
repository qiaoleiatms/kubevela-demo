"ingress": {
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
        domain: string
        http: [string]: int
    }

    outputs: ingress: {
        apiVersion: "networking.k8s.io/v1"
        kind:       "Ingress"
        metadata: {
            name: "httprule-" + context.name
        }
        spec: {
            rules: [{
                host: parameter.domain
                http: {
                    paths: [
                        for k, v in parameter.http {
                            path: k
                            backend: {
                                serviceName: context.name
                                servicePort: v
                            }
                        },
                    ]
                }
            }]
        }
    }
}