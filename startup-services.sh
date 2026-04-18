#!/bin/bash

# Startup script for DevOps services
# This script starts Docker, K3s, Jenkins and waits for monitoring pods

echo "Starting DevOps services..."

# Enable swap if not already enabled
if [ $(swapon --show | wc -l) -eq 0 ]; then
    sudo swapon /swapfile 2>/dev/null || true
fi

# Start and enable Docker
echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Start and enable K3s
echo "Starting K3s..."
sudo systemctl start k3s
sudo systemctl enable k3s

# Wait for K3s to be ready
echo "Waiting for K3s..."
until kubectl get nodes 2>/dev/null | grep -q "Ready"; do
    sleep 5
done
echo "K3s is ready"

# Start and enable Jenkins
echo "Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Wait for monitoring pods
echo "Waiting for pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s 2>/dev/null || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s 2>/dev/null || true

# Display service status
echo ""
echo "======================================"
echo "  Services Status After Boot"
echo "======================================"
echo "Docker: $(sudo systemctl is-active docker)"
echo "K3s: $(sudo systemctl is-active k3s)"
echo "Jenkins: $(sudo systemctl is-active jenkins)"
echo ""
echo "Pods:"
kubectl get pods -n monitoring 2>/dev/null | grep -E "grafana|prometheus" || echo "Monitoring not deployed"
kubectl get pods 2>/dev/null | grep myapp || echo "App not deployed"
echo ""
echo "Access URLs:"
PUBLIC_IP=$(curl -s ifconfig.me)
echo "  Jenkins:     http://${PUBLIC_IP}:8080"
echo "  Grafana:     http://${PUBLIC_IP}:30000"
echo "  Prometheus:  http://${PUBLIC_IP}:30001"
echo "  App:         http://${PUBLIC_IP}:30010"
echo ""
echo "[$(date)] Startup complete!"
