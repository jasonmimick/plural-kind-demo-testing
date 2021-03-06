The [plural-demo.sh](plural-demo.sh) script contains a basic
first deployment of the kind-console.

The goal is to have a simple repeatable basic e-2-e demo of a cluster
with a control plane and then one simple app (the app is not
yet in the demo script).


# Running the demo

```
$./plural-demo.sh <optional-repo-name>
```

Follow the prompts.

TODO: Script a context.yaml from script inputs.
_or_ is there a way to pass these values to `plural deploy`?


# Findings

In this example, we ran:

```
./plural-demo demo-one-a
```

Here's the generated context.yaml:

```
apiVersion: plural.sh/v1alpha1
kind: Context
spec:
  bundles:
  - repository: console
    name: console-kind
  configuration:
    bootstrap: {}
    console:
      admin_email: jmimick@gmail.com
      admin_name: Jason
      console_dns: console.demo-one-a.onplural.sh
      git_email: jmimick@gmail.com
      git_user: jasonmimick
      passphrase: ""
      private_key: |
        -----BEGIN OPENSSH PRIVATE KEY-----
OMITTED
        -----END OPENSSH PRIVATE KEY-----
      public_key: |
OMITTED
      repo_url: git@github.com:jasonmimick/demo-one-a.git
    etcd: {}
    ingress-nginx: {}
    minio:
      consoleHostname: minio-console.demo-one-a.onplural.sh
      hostname: minio.demo-one-a.onplural.sh
    monitoring: {}
    postgres:
      wal_bucket: demo-one-a-demo-one-a-postgres-wal
```
- First time when the `plural build` command runs, seeing a error 
graphql and gcp. We didn't select anything GCP related:

```
**NOTE** :: To edit the configuration you've just entered, edit the context.yaml file at the root of your repo, or run with the --refresh flag
2022/04/25 10:34:55 graphql: provider gcp does not match supported providers [kind]
Building workspace for bootstrap
unpacking 2 modules..✓
syncing crds................................................✓
helm dependency update ~> ..............✓
Finished building bootstrap
```

- After running the demo script getting a syntax error in a terraform
file:

```
plural deploy --commit "$(whoami)'s 2nd deployment"
Deploying applications [bootstrap, ingress-nginx, etcd, minio, postgres, monitoring, console] in topological order

deploying bootstrap, hold on to your butts
terraform init -upgrade ~> ..
Output:

There are some problems with the configuration, described below.

The Terraform configuration must be valid before initialization so that
Terraform can determine which modules and providers need to be installed.
╷
│ Error: Invalid expression
│ 
│ On main.tf line 47: Expected the start of an expression, but found an
│ invalid expression token.
╵


**NOTE** :: It looks like your deployment failed, feel free to reach out to us on discord or intercom and we should be able to help you out
exit status 1
```


Upon checking `/demo-one-a/bootstrap/terraform/main.tf` we see:

```
 39 ### BEGIN MANUAL SECTION <<gcp-bootstrap>>                            
 40                                                                       
 41 ### END MANUAL SECTION <<gcp-bootstrap>>                              
 42                                                                       
 43                                                                       
 44                                                                       
 45   gcp_project_id = ""                                                 
 46   cluster_name = "demo-one-a"                                         
 47   vpc_name_prefix =                                                   
 48   externaldns_sa_name = "demo-one-a-externaldns"                      
 49   gcp_region = "us-east-1"                                            
 50   network_policy_enabled = false                                      
 51   datapath_provider = "ADVANCED_DATAPATH"                             
 52                                                                       
 53                                               
```

After attempting to comment out all the GCP stuff, do we need it?
Getting more errors:


```
 cd demo-one-a 
[jason@jerry ~/lab/plural/plural-kind-demo-testing/demo-one-a]$ plural deploy --commit "$(whoami)'s 2nd deployment"
Deploying applications [bootstrap, ingress-nginx, etcd, minio, postgres, monitoring, console] in topological order

deploying bootstrap, hold on to your butts
terraform init -upgrade ~> .................
Output:

Upgrading modules...
- gcp-bootstrap in gcp-bootstrap
Downloading registry.terraform.io/terraform-google-modules/kubernetes-engine/google 20.0.0 for gcp-bootstrap.certmanager-workload-identity...
- gcp-bootstrap.certmanager-workload-identity in .terraform/modules/gcp-bootstrap.certmanager-workload-identity/modules/workload-identity
Downloading registry.terraform.io/terraform-google-modules/gcloud/google 3.1.1 for gcp-bootstrap.certmanager-workload-identity.annotate-sa...
- gcp-bootstrap.certmanager-workload-identity.annotate-sa in .terraform/modules/gcp-bootstrap.certmanager-workload-identity.annotate-sa/modules/kubectl-wrapper
- gcp-bootstrap.certmanager-workload-identity.annotate-sa.gcloud_kubectl in .terraform/modules/gcp-bootstrap.certmanager-workload-identity.annotate-sa
Downloading registry.terraform.io/terraform-google-modules/kubernetes-engine/google 20.0.0 for gcp-bootstrap.externaldns-workload-identity...
- gcp-bootstrap.externaldns-workload-identity in .terraform/modules/gcp-bootstrap.externaldns-workload-identity/modules/workload-identity
Downloading registry.terraform.io/terraform-google-modules/gcloud/google 3.1.1 for gcp-bootstrap.externaldns-workload-identity.annotate-sa...
- gcp-bootstrap.externaldns-workload-identity.annotate-sa in .terraform/modules/gcp-bootstrap.externaldns-workload-identity.annotate-sa/modules/kubectl-wrapper
- gcp-bootstrap.externaldns-workload-identity.annotate-sa.gcloud_kubectl in .terraform/modules/gcp-bootstrap.externaldns-workload-identity.annotate-sa
Downloading git::https://github.com/pluralsh/terraform-google-kubernetes-engine.git?ref=filestore-csi-driver for gcp-bootstrap.gke...
- gcp-bootstrap.gke in .terraform/modules/gcp-bootstrap.gke
- kind-bootstrap in kind-bootstrap
There are some problems with the configuration, described below.

The Terraform configuration must be valid before initialization so that
Terraform can determine which modules and providers need to be installed.
╷
│ Error: Duplicate output definition
│ 
│   on outputs.tf line 13:
│   13: output "cluster" {
│ 
│ An output named "cluster" was already defined at outputs.tf:1,1-17. Output
│ names must be unique within a module.
╵


**NOTE** :: It looks like your deployment failed, feel free to reach out to us on discord or intercom and we should be able to help you out
exit status 1
```




# Tools Versions

Here's the output for my tool versions:

```
./tool-versions.sh 
+ docker version
Client:
 Version:           20.10.12
 API version:       1.41
 Go version:        go1.16.15
 Git commit:        e91ed5707e
 Built:             Mon Mar 21 06:17:35 2022
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.12
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.16.15
  Git commit:       459d0df
  Built:            Mon Mar 21 06:18:08 2022
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.4.12
  GitCommit:        7b11cfaabd73bb80907dd23182b9347b4245eb5d
 runc:
  Version:          1.0.2
  GitCommit:        
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
+ kind version
kind v0.12.0 go1.17.8 linux/amd64
+ kubectl version
Client Version: version.Info{Major:"1", Minor:"16", GitVersion:"v1.16.0", GitCommit:"2bd9643cee5b3b3a5ecbd3af49d09018f0773c77", GitTreeState:"clean", BuildDate:"2019-09-18T14:36:53Z", GoVersion:"go1.12.9", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server 127.0.0.1:46291 was refused - did you specify the right host or port?
+ plural version
Plural CLI:
  Version: 0.1.1
  Git Commit: fd3f29f
  Compiled At: 2022-04-25 10:46:54.364377106 -0400 EDT m=+0.013948280
  OS: linux
  Arch: amd64
+ terraform version
Terraform v1.1.9
on linux_amd64
```
