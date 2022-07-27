# Policies

This policy let you control the name on the ingress created in each namespace

### Pre-requisites

Enable AKS policy add-on on the cluster and create a private DNS Zone (not required for testing)

### Parameters

domainName : domain to match. For eg : dev.mydomain.com

### How it works

Eeach time a ingress is created in a applicative namespace, the policy check the host parameters in the ingress http rule definition.

Let say you have a namespace called app1, granted http rule name must have this pattern : *.namespace.domainName

namespace : app1
domainName: dev.mydomain.com

With those parameters, the pattern will be : *.app1.dev.mydomain.com for the app1 namespace. Only ingress with http rules that match this pattern will be allowed to be created.

If you try to create an ingress with this host in app1 namespace : web.app2.dev.mydomain.com will not work

