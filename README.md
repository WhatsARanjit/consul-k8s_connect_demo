# Overview

Setup a dummy web/db app in GKE.  Show usage without Consul Connect.  Turn on Connect without changing the app to show mTLS in use.

## Setup WebApp without Connect

1. Create a GKE Cluster with the defaults.

1. Connect to the cluster.

1. Clone this repo.
    ```
    git clone From https://github.com/WhatsARanjit/consul-k8s_connect_demo
    cd consul-k8s_connect_demo/
    ```

1. Create Consul pod and surrounding dependencies.
    ```
    kubectl create -f pods/consul.yaml
    ```

1. Determine the Consul service address either in the UI or with:
    ```
    kubectl get services consul-service
    # or
    kubectl get services consul-service -o jsonpath='{.status.loadBalancer.ingress[0].ip'} && echo
    ```
    The Consul UI will be at http://<consul_service_address>:8500.

1. Create database pod.
    ```
    kubectl create -f pods/db.yaml
    ```

1. Check Consul to make sure `db` and `db-proxy` services get registered.

1. In the Consul UI, note the IP address of the db node and save this value in a configmap:
    ```
    DB_IP=$(kubectl get pods -o json | jq -r '.items[] | select(.metadata.name|test("^db")) | .status.podIP')
    kubectl create configmap db --from-literal=ip=$DB_IP
    ```
    _Note:_ Without configuring/managing k8s DNS, we end up hard-coding IPs.

1. Create web pod and web service.
    ```
    kubectl create -f pods/web.yaml
    kubectl create -f pods/web-service.yaml
    ```

1. Check Consul to make sure `web` and `web-proxy` services get registered.

1. Determine the web service address either in the UI or with:
    ```
    kubectl get services web-service
    # or
    kubectl get services web-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' && echo
    ```
    The webapp will be at http://<web_service_address>.

## Inspect HTTP traffic

1. List pods to find the db pod's ID:
    ```
    kubectl get pods
    # OR
    DB_ID=$(kubectl get pods -o json | jq -r '.items[] | select(.metadata.name|test("^db")) | .metadata.name')
    ```

1. Log into the db pod:
    ```
    kubectl exec -it $DB_ID t -c db -- bash
    ```

1. TCPDump on port 8081:
    ```
    tcpdump -v -s 1024 -l -A dst port 8081
    ```
    Observe the plain-text traffic and potential `password` in payload.

## Redeploy with Connect

1. Remove current components.
    ```
    kubectl delete -f pods/db.yaml
    kubectl delete -f pods/web.yaml
    ```
    _Important:_ Let the services get de-registered from Consul before proceeding.

1. Set the database IP to localhost to use Connect.
    ```
    kubectl delete configmap db
    kubectl create configmap db --from-literal=ip=localhost
    ```

1. Redeploy db/web pods.
    ```
    kubectl create -f pods/db.yaml
    kubectl create -f pods/web.yaml
    ```
    And refresh web page.

## Inspect HTTPS traffic

1. List pods to find the db pod's ID:
    ```
    kubectl get pods
    # OR
    DB_ID=$(kubectl get pods -o json | jq -r '.items[] | select(.metadata.name|test("^db")) | .metadata.name')
    ```

1. Log into the db pod:
    ```
    kubectl exec -it $DB_ID t -c db -- bash
    ```

1. Find upstream Connect database port under `db-proxy` in the Consul UI.

1. TCPDump on Connect database port:
    ```
    tcpdump -v -s 1024 -l -A dst port <connect_port>
    ```
    Observe the garbled traffic and the SPIFFE exchanges instead.

