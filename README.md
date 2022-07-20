# aks-starter
These scripts are only samples in order to help applications starting with AKS

createcluster: ssh script to create an AKS cluster
<br/>
initcluster: helm chart that will initialize the cluster
- Create cluster roles that will be used by new projects 
- Install an internal nginx controller with a wildcard certificate (should be in a KV - CSI driver)

<br/>
initproject: helm chart that will create a new project
- Create a namespace 
- Create rolebindings 
- Create a storageclass and PVC (azure file dynamically)
- Add quota on CPU and memory 
