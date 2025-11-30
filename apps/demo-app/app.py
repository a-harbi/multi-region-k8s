from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

@app.route('/')
def home():
     # Returns cluster info to verify load balancing across regions.
    return jsonify({
        'message': 'Hello from HA Kubernetes Platform!',
        'hostname': socket.gethostname(),  # Hostname shows which pod handled the request.
        'cluster': os.getenv('CLUSTER_NAME', 'unknown'),
        'version': 'v1.0'
    })

@app.route('/health')
def health():
    """Health check endpoint for load balancer"""
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
