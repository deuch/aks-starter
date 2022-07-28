# DNS

Rewrite DNS with coredns

### How it works

Modify the coredns.yaml file with the domain you want. In the example, it's *.aks-internal.com.

All DNS resolution sent for *.aks-internal.com will be rewritten in *.svc.cluster.local.

Eg : webfront.app1.aks-internal.com -> webfront.app1.svc.cluster.local

You need to have certificate in your pods that can handle the *.aks-internal.com domain.

For the ingress part, you can add an annotation to change the initial http host :

nginx.ingress.kubernetes.io/upstream-vhost: webfront.app1.aks-internal.com

