from flask import Flask, jsonify, render_template_string
import socket
import os

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>HA Platform</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: #f5f5f5;
            margin: 0;
        }
        .container {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 500px;
        }
        h1 { color: #333; text-align: center; }
        .info { margin: 1rem 0; padding: 1rem; background: #f9f9f9; border-radius: 4px; }
        .label { color: #666; font-weight: bold; }
        .value { color: #0066cc; font-family: monospace; }
        .status { text-align: center; margin-top: 2rem; }
        .dot { display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: #22c55e; margin-right: 8px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🇸🇦 Hello from Saudi Arabia HA Platform! 🇸🇦</h1>
        <div class="info">
            <div class="label">Cluster:</div>
            <div class="value">{{ cluster }}</div>
        </div>
        <div class="info">
            <div class="label">Host / Pod:</div>
            <div class="value">{{ hostname }}</div>
        </div>
        <div class="info">
            <div class="label">Version:</div>
            <div class="value">{{ version }}</div>
        </div>
        <div class="info">
            <div class="label">Load Balancer:</div>
            <div class="value">HAProxy Active ✅</div>
        </div>
        <div class="status">
            <span class="dot"></span>
            <span>Online</span>
        </div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    """Main endpoint - returns beautiful HTML page"""
    return render_template_string(
        HTML_TEMPLATE,
        cluster=os.getenv('CLUSTER_NAME', 'unknown'),
        hostname=socket.gethostname(),
        version='v3.0'
    )

@app.route('/api')
def api():
    """API endpoint - returns JSON"""
    return jsonify({
        'message': 'Hello from Saudi Arabia HA Platform!',
        'hostname': socket.gethostname(),
        'cluster': os.getenv('CLUSTER_NAME', 'unknown'),
        'version': 'v3.0',
        'load_balancer': 'HAProxy Active'
    })

@app.route('/health')
def health():
    """Health check endpoint for load balancer"""
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
