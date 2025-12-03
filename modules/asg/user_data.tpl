#!/bin/bash
yum update -y
yum install -y nginx
systemctl enable nginx
systemctl start nginx
cat > /usr/share/nginx/html/index.html <<'EOF'
<html>
  <head><title>Terraform ASG Demo</title></head>
  <body><h1>Hello from Terraform-deployed EC2</h1></body>
</html>
EOF
