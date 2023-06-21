# docker-argocd-cmp-helmfile

This repository builds a docker image that can be run as a sidecar alongside ArgoCD to enable the support of helmfile.

You simply need to patch your **argocd-repo-server** manifest by adding :

```
containers:
- command:
  - /var/run/argocd/argocd-cmp-server
  image: ghcr.io/camptocamp/docker-argocd-cmp-helmfile:0.x.x
  imagePullPolicy: IfNotPresent
  name: cmp-helmfile
  resources: {}
  securityContext:
    runAsNonRoot: true
    runAsUser: 999
  terminationMessagePath: /dev/termination-log
  terminationMessagePolicy: File
  volumeMounts:
  - mountPath: /var/run/argocd
    name: var-files
  - mountPath: /home/argocd/cmp-server/plugins
    name: plugins
  - mountPath: /tmp
    name: cmp-tmp

[...]

volumes:
  - emptyDir: {}
    name: cmp-tmp
```

For more information please read the [official documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/config-management-plugins/#option-2-configure-plugin-via-sidecar)


## How it works :

The plugin will detect any applications with a helmfile.yaml file inside and run the argocd-helmfile script to generate the YAML.
 - init phase :
   - if a charts/ folder exists it will **only** use the charts inside.
   - else it will launch helmfile fetch to download the remote charts defined in the dependencies sections of the Chart.yaml (and respecting the constraints of the Chart.lock). Since the fetch uses the helm dependency build subcommand you have to define all your remote repositories in the helmfile.yaml.
  
 - generate phase :
   - the plugin will parse the first release in the helmfile.yaml for secrets and the values in the ARGOCD_ENV_ADDITIONAL_VALUES envvar if it exists and pass them as arguments for helm.
   - launch helmfile template with the params above.
