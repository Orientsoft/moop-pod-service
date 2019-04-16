# pod-service

K8s pod management service, customized for MOOP API Server.  

## tenant resources

podInYaml:  

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: copy-vol-job
spec:
  ttlSecondsAfterFinished: 0
  template:
    spec:
      containers:
      - name: copy
        image: podbox:latest
        imagePullPolicy: IfNotPresent
        args:
          - /bin/sh
          - -c
          - cp -r /src/* /dest/
        volumeMounts:
        - name: gluster-vol1
          mountPath: /dest
        - name: nfs-vol1
          mountPath: /src
      restartPolicy: Never
      volumes:
      - name: gluster-vol1
        persistentVolumeClaim:
          claimName: gluster-exam
      - name: nfs-vol1
        persistentVolumeClaim:
          claimName: nfs-exam
```

Save pod template in tenant resources.templates field:  

podTemplate:  

```js
{
    "apiVersion": "batch/v1",
    "kind": "job",
    "metadata": {
        "name": "job-{}-{}" // name template - "job-{tenantId}-{hash}"
    },
    "spec": {
        "ttlSecondsAfterFinished": 0,
        "template": {
            "spec": {
                "containers": [
                    {
                        "name": "copy",
                        "image": "podbox:latest",
                        "imagePullPolicy": "IfNotPresent",
                        "args": [
                            "/bin/sh",
                            "-c",
                            "{}" // cmd - eg. "cp -r /src/* /dest/"
                        ],
                        "volumeMounts": []
                    }
                ],
                "restartPolicy": "Never",
                "volumes": []
            }
        }
    }
}
```

## K8S namespace

**After creating tenant, please create a k8s namespace with tenant.namespace.**  

## images

During deployment, please build alpine or busybox image with dockerfiles in the project root.  
Record image tag for further tenant setup.  

## config.yaml

Please place config.yaml under the root of pod service.  

config.yaml:  
```yaml
host: '0.0.0.0'
port: 5020
debug: true
# 10 - debug
log_level: 10
tenant_service_url: 'http://192.168.0.48:7778/service/v1/tenants'
```

## dev start

```sh
python pod-service.py
```

## API

**Do NOT rely on returned value of POST APIs, K8S may return null if the resource couldn't be created in time!!!**  

### pod

podInRequest:  

```js
{
    "tenant": ObjectID, // tenant id
    "cmd": String,
    "vols": [
        {
            "pvc": String, // PVC name
            "mount": String, // mount point
        }
    ]
}
```

podInResponse (sample):  

```js

```

| method | path | query | request | response | remark |
| ------ | ---- | ----- | ------- | -------- | ------ |
| POST | /pods | | podInRequest | podInResponse | 创建pod |
| GET | /pods | | | podInResponse | 查询pod |
| DELETE | /pods | | | | 删除指定pod |
