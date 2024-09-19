#!/bin/bash  

# Container names to monitor  
CONTAINERS=(  
  "retool-onpremise-master_api_1"  
  "retool-onpremise-master_code-executor_1"  
  "retool-onpremise-master_https-portal_1"  
  "retool-onpremise-master_jobs-runner_1"  
  "retool-onpremise-master_postgres_1"  
  "retool-onpremise-master_retooldb-postgres_1"  
  "retool-onpremise-master_workflows-backend_1"  
  "retool-onpremise-master_workflows-worker_1"  
  "temporal-admin-tools"  
  "temporal-ui"  
)  

# Directory containing your docker-compose.yml file  
COMPOSE_DIR="/home/azureuser/retool-onpremise-master"  

# Fetch all containers' statuses once  
containers_status=$(sudo docker ps -a --format "{{.Names}}:{{.State}}")  

# Function to check the status of a container  
check_container_status() {  
    local container=$1  
    local container_status=$(echo "$containers_status" | grep "^$container:" | cut -d ':' -f 2)  
    if [ -n "$container_status" ]; then  
        if [ "$container_status" == "running" ]; then  
            return 0  
        else  
            return 1  
        fi  
    else  
        return 1  
    fi  
}  

echo "$(date)"  
echo "---------------------------------------------------------------------------------"  

for container in "${CONTAINERS[@]}"; do  
    if ! check_container_status "$container"; then  
        echo "$container : Exited"  
        cd "$COMPOSE_DIR"  
        sudo docker-compose up -d api temporal-admin-tools temporal-ui  
        echo "Restarted services ..........."  
        echo "---------------------------------------"  
        sudo docker-compose ps  
        break  
    else  
        echo "$container : Up"  
    fi  
done