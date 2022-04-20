# Represents the non-helm approach to implementing external DNS.
# The external DNS 'azure.json' file is used to configure the external DNS provider
# and has to be created before these resources can be created. See 06-external-dns-secret.tf 
# and the non-helm instructions at: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md


resource "kubernetes_manifest" "serviceaccount_external_dns" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "external-dns"
    }
  }
}



resource "kubernetes_service_account" "serviceaccount_external_dns" {
  metadata {
    name        = "external-dns"
    annotations = {}
    labels      = {}
  }
  #secret {
  #  name = "${kubernetes_secret.example.metadata.0.name}"
  #}
}

resource "kubernetes_manifest" "clusterrole_external_dns" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "name" = "external-dns"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
          "endpoints",
          "pods",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "networking.k8s.io",
        ]
        "resources" = [
          "ingresses",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "list",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_external_dns_viewer" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = "external-dns-viewer"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "external-dns"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "external-dns"
        "namespace" = "default"
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_external_dns" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "external-dns"
      "namespace" = "external-dns"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "external-dns"
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "external-dns"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--source=service",
                "--source=ingress",
                "--provider=azure",
                "--azure-resource-group=${var.resource_group_name}",
                "--txt-prefix=externaldns-",
              ]
              "image" = "k8s.gcr.io/external-dns/external-dns:v0.8.0"
              "lifecycle" = {
                "postStart" = {
                  "exec" = {
                    "command" = [
                      "/bin/sh",
                      "-c",
                      "echo hello world",
                    ]
                  }
                }
              }
              "name" = "myapp"
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/kubernetes"
                  "name"      = "azure-config-file"
                  "readOnly"  = true
                },
              ]
            },
          ]
          "serviceAccountName" = "external-dns"
          "volumes" = [
            {
              "name" = "azure-config-file"
              "secret" = {
                "secretName" = "azure-config-file"
              }
            },
          ]
        }
      }
    }
  }
  depends_on = [
    kubernetes_secret.azure_config_file,
  ]
}