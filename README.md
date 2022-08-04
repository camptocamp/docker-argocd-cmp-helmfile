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
