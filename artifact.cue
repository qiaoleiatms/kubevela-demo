artifact: {
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "apps/v1"
		kind:       "Deployment"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		spec: {
			selector: matchLabels: "app.oam.dev/component": context.name
			template: {
				metadata: labels: "app.oam.dev/component": context.name
				spec: {
					containers: [{
						name:  context.name
						if parameter.javaVersion == "8" {
						image: "mcr.microsoft.com/azurespringapps/java/jdk:8-msopenjdk-mariner-8dbc1ef2-33909-2023-12-06"
						}
						if parameter.javaVersion == "11" {
						image: "mcr.microsoft.com/azurespringapps/java/jdk:11-msopenjdk-mariner-8dbc1ef2-33909-2023-12-06"
						}
						if parameter.javaVersion == "17" {
						image: "mcr.microsoft.com/azurespringapps/java/jdk:17-msopenjdk-mariner-8dbc1ef2-33909-2023-12-06"
						}
						if parameter.javaVersion == "21" {
						image: "mcr.microsoft.com/azurespringapps/java/jdk:21-msopenjdk-mariner-8dbc1ef2-33909-2023-12-06"
						}
						imagePullPolicy: "IfNotPresent"
						command: ["sh", "-c"]
						args: ["java -XX:InitialRAMPercentage=60.0 -XX:MaxRAMPercentage=60.0 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.local.only=true -Dmanagement.endpoints.jmx.exposure.include=health,metrics -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dspring.jmx.enabled=true -Dserver.tomcat.mbeanregistry.enabled=true -Dfile.encoding=UTF8 " + parameter.javaagent + " -jar /tmp/" + parameter.jarFileName + ".jar"]
						ports: [{
							containerPort: parameter.port
							name: "app-port"
							protocol: "TCP"
						}]
						volumeMounts: [
							{
								mountPath: "/tmp"
					          	name: context.name + "-temp"
							}
						]
					}]
					initContainers: [{
						name: "i"
						image: "mcr.microsoft.com/azurespringapps/azure-spring-cloud-apps-initial:1.0.02570.1021-generic-506d9bdd"
						imagePullPolicy: "IfNotPresent"
						terminationMessagePath: "/dev/termination-log"
						terminationMessagePolicy: "File"
						args: ["cp /jar/" + parameter.jarFileName + " /tmp/" + parameter.jarFileName + ".jar"]
						command: ["sh", "-c"]
						volumeMounts: [
							{
								mountPath: "/jar"
								name: "builtin-azurefile-name"
							},
							{
								mountPath: "/tmp"
					          	name: context.name + "-temp"
							}
						]
					}]
					volumes: [
						{
							name: "builtin-azurefile-name"
							csi: {
								driver: "file.csi.azure.com"
								readOnly: true
								volumeAttributes: {
									secretName: parameter.storageAccountSecret
									shareName: context.name
								}
							}
						},
						{
							emptyDir: {
								sizeLimit: "5Gi"
							}
							name: context.name + "-temp"
						}
					]
				}				 
			}
		}
		apiVersion: "apps/v1"
		kind:       "Deployment"
	}
	outputs: appservice: {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {
			name: 	context.name
		}
		spec: {
			selector: {
				"app.oam.dev/component": context.name
			}
			ports: [{
					port:       parameter.port
					targetPort: parameter.port
			}]
		}
	}
	parameter: {
		jarFileName: string
		javaVersion: string
		storageAccountSecret: string
		port: int
		javaagent?: string
	}
}
