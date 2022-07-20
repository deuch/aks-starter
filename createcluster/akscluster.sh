region="eastus"
rgname="aksrg"
admingroup="akscls"
subscriptionid=""
vnetname="kubevnet"
vnetprefix="10.20.0.0/22"
akssubnetname="akssubnet"
akssubnetprefix="10.20.0.0/24"
ilbsubnetname="ilbsubnet"
ilbsubnetprefix="10.20.1.0/24"
micpname="aksmicp"
mikubeletname="aksmikubelet"
aksclustername="kubecls"

#create resource group for aks
az group create --name $rgname --location $region

export KUBECONFIG=/mnt/c/Users/lhabdas/.kube/config

# create 2 managed identities 
# Used by AKS control plane components to manage cluster resources including ingress load balancers and AKS managed public IPs, Cluster Autoscaler, Azure Disk & File CSI drivers
az identity create --name $micpname --resource-group $rgname
# Authentication with Azure Container Registry (ACR)
az identity create --name $mikubeletname --resource-group $rgname


# Create AKS admin group in azure ad
#az ad group create --display-name $admingroup --mail-nickname $admingroup
group=$(az ad group list --filter "displayname eq '$admingroup'" --query [0].objectId  --out tsv)
group=$(echo $group | sed 's/\r$//')

az network vnet create --address-prefixes $vnetprefix --name $vnetname --resource-group $rgname --subnet-name $akssubnetname --subnet-prefixes $akssubnetprefix
az network vnet subnet create --name $ilbsubnetname --vnet-name $vnetname --resource-group $rgname --address-prefixes $ilbsubnetprefix

az ad sp create-for-rbac -n $micpname --role "Network Contributor" --scopes "/subscriptions/${subscriptionid}/resourceGroups/${rgname}/providers/Microsoft.Network/virtualNetworks/${vnetname}/subnets/${akssubnetname}"
az ad sp create-for-rbac -n $micpname --role "Network Contributor" --scopes "/subscriptions/${subscriptionid}/resourceGroups/${rgname}/providers/Microsoft.Network/virtualNetworks/${vnetname}/subnets/${ilbsubnetname}"

# create aks cluster with admin group + no local admin + enable rbac + CNI + add on CSI driver (KV)
az aks create \
    --resource-group $rgname \
    --name $aksclustername \
    --network-plugin azure \
    --vnet-subnet-id /subscriptions/${subscriptionid}/resourceGroups/${rgname}/providers/Microsoft.Network/virtualNetworks/${vnetname}/subnets/${akssubnetname} \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.10.0.10 \
    --service-cidr 10.10.0.0/24 \
    --generate-ssh-keys \
    --node-vm-size Standard_D4s_v4 \
    --enable-cluster-autoscaler \
    --min-count 3 \
    --max-count 6 \
    --assign-identity /subscriptions/${subscriptionid}/resourcegroups/${rgname}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${micpname} \
    --assign-kubelet-identity /subscriptions/${subscriptionid}/resourcegroups/${rgname}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${mikubeletname} \
    --enable-aad --aad-admin-group-object-id $group --disable-local-accounts \
    --enable-addons azure-keyvault-secrets-provider
#--enable-private-cluster

az aks get-credentials --resource-group $rgname --name $aksclustername

# to do
# setup KV + nginx certif in KV
# add rights in KV to MI get / list on key/secret/certif

# config cluster
kubectl create ns ingress
helm install -f initclustervalues.yaml initcluster initcluster --version 1.0.0 --namespace ingress

# config project
helm install -f initprojectvalues.yaml initprojectapp1 initproject --version 1.0.0


# test pvc
kubectl get pvc -n app1


# how to activate azure policy for AKS
#https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes#install-azure-policy-add-on-for-aks
#https://docs.microsoft.com/en-us/azure/aks/use-azure-policy?toc=%2Fazure%2Fgovernance%2Fpolicy%2Ftoc.json&bc=%2Fazure%2Fgovernance%2Fpolicy%2Fbreadcrumb%2Ftoc.json
az provider register --namespace Microsoft.PolicyInsights

az aks enable-addons --addons azure-policy --name $aksclustername  --resource-group $rgname

# azure-policy pod is installed in kube-system namespace
kubectl get pods -n kube-system

# gatekeeper pod is installed in gatekeeper-system namespace
kubectl get pods -n gatekeeper-system

