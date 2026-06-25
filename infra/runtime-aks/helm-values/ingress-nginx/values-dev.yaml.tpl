controller:
  replicaCount: 2

  service:
    type: LoadBalancer
    externalTrafficPolicy: Cluster
    annotations:
      service.beta.kubernetes.io/azure-pip-name: "${ingress_public_ip_name}"
      service.beta.kubernetes.io/azure-load-balancer-resource-group: "${foundation_resource_group_name}"
      service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz

  ingressClassResource:
    name: nginx
    enabled: true
    default: false

  ingressClass: nginx

  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: ingress-nginx
          app.kubernetes.io/component: controller

  metrics:
    enabled: true