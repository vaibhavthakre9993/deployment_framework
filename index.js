const http = require('http');
const port = process.env.PORT || 3000;
const appName = process.env.APP_NAME || 'deployment-framework';

const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xoriant Deployment Platform</title>
    <style>
        :root {
            --primary: #002B5C; /* Navy Blue */
            --accent: #FF6600; /* Orange */
            --bg: #F4F7F6;
            --text: #333333;
            --white: #FFFFFF;
        }
        
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg);
            color: var(--text);
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        header {
            background-color: var(--primary);
            color: var(--white);
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .logo {
            font-size: 24px;
            font-weight: 800;
            letter-spacing: 2px;
            color: var(--white);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo span {
            color: var(--accent);
        }

        .badge {
            background-color: #28a745;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .badge::before {
            content: '';
            display: inline-block;
            width: 10px;
            height: 10px;
            background-color: white;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 1; }
            50% { transform: scale(1.2); opacity: 0.7; }
            100% { transform: scale(0.95); opacity: 1; }
        }

        main {
            flex: 1;
            padding: 40px;
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
            box-sizing: border-box;
        }

        .hero {
            text-align: center;
            margin-bottom: 50px;
        }

        h1 {
            color: var(--primary);
            font-size: 2.5rem;
            margin-bottom: 10px;
        }

        .subtitle {
            font-size: 1.2rem;
            color: #666;
            margin-bottom: 20px;
        }

        .app-name {
            display: inline-block;
            background-color: var(--accent);
            color: white;
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: bold;
            margin-top: 10px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
            margin-top: 40px;
        }

        .card {
            background: var(--white);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            border-top: 4px solid var(--accent);
            transition: transform 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        .card h3 {
            color: var(--primary);
            margin-top: 0;
            font-size: 1.2rem;
        }

        .card p {
            color: #555;
            line-height: 1.6;
            margin-bottom: 0;
        }

        footer {
            background-color: var(--primary);
            color: rgba(255,255,255,0.7);
            text-align: center;
            padding: 20px;
            font-size: 0.9rem;
            margin-top: auto;
        }

        @media (max-width: 768px) {
            header {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            main {
                padding: 20px;
            }
            h1 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="logo">XORIANT<span>.</span></div>
        <div class="badge">Platform Status: Live</div>
    </header>

    <main>
        <div class="hero">
            <h1>Self-Service Deployment Platform</h1>
            <div class="subtitle">Powered by Azure Container Apps</div>
            <div class="app-name">App: ${appName}</div>
        </div>

        <div class="grid">
            <div class="card">
                <h3>🚀 Auto Deployment</h3>
                <p>Seamless CI/CD pipeline integrated directly with GitHub Actions. Just git push to deploy your code automatically to Azure.</p>
            </div>
            <div class="card">
                <h3>🐳 Docker Containerization</h3>
                <p>Applications are automatically packaged into lightweight, portable Docker containers ensuring consistency across environments.</p>
            </div>
            <div class="card">
                <h3>🛡️ ModSecurity WAF Protection</h3>
                <p>Enterprise-grade Web Application Firewall using Nginx and the OWASP Core Rule Set to block malicious traffic instantly.</p>
            </div>
            <div class="card">
                <h3>☁️ Azure Cloud Infrastructure</h3>
                <p>Highly available, scalable, and secure infrastructure provisioned automatically via Terraform on Microsoft Azure.</p>
            </div>
            <div class="card">
                <h3>⚙️ Terraform Infrastructure as Code</h3>
                <p>Infrastructure is fully automated using Terraform. Every resource on Azure is provisioned, managed and destroyed through code — no manual setup required.</p>
            </div>
        </div>
    </main>

    <footer>
        &copy; 2026 Xoriant Solutions. All rights reserved.
    </footer>
</body>
</html>
`;

const server = http.createServer((req, res) => {
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end('OK');
    } else {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(htmlContent);
    }
});

server.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
