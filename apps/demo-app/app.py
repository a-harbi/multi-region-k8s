from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

@app.route('/')
def home():
    """Main endpoint - returns cluster and pod info"""
    return jsonify({
        'message': ' Hello from Saudi Arabia HA Platform! 🇸🇦',
        'hostname': socket.gethostname(),
        'cluster': os.getenv('CLUSTER_NAME', 'unknown'),
        'version': 'v2.0',
        'gitops': 'ArgoCD Auto-Deployed! '
    })

@app.route('/health')
def health():
    """Health check endpoint for load balancer"""
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
