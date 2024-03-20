"blue-green": {
    description: "Active deployment policy."
    type:        "policy"
}

template: {
    parameter: {
        active: string
        port: int
    }

    output: {
        apiVersion: "v1"
        kind:       "Service"
        metadata: name: context.name
        spec: {
            selector: {
                "app.oam.dev/component": parameter.active
            }
            ports: [{
                port:       parameter.port
                targetPort: parameter.port
            }]
        }
    }
}