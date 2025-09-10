# Basic Configuration
environment = "dev"
location    = "centralus"
project     = "pokedata"

# Ownership
owner       = "Mike Abernathy"
cost_center = "Development"

# GitHub Configuration (for Static Web App)
github_repository_url = "https://github.com/Abernaughty/PokeData"
github_branch         = "main"

# API Management
apim_publisher_name  = "PokeData Development Team"
apim_publisher_email = "mike@maber.io"

# Optional: Override default SKUs (leave commented to use environment defaults)
# cosmos_capacity_mode = "Serverless"
# function_app_sku     = "Y1"
# static_web_app_sku   = "Free"
# apim_sku            = "Consumption"

# Networking (dev typically uses public access)
enable_private_endpoints = false
allowed_ip_ranges        = [] # Empty for public access, or add your IPs like ["1.2.3.4/32"]

# Monitoring
enable_monitoring  = true
log_retention_days = 30

# Features
enable_auto_scaling   = false # Not needed for dev
enable_backup         = true
backup_retention_days = 7
