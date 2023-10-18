#!/bin/bash
config_file="employee-api/config.yaml"
scylla_host="10.0.6.180:9042"
scylla_username="scylladb"
scylla_password="password"
scylla_keyspace="employee_db"
redis_enabled="true"
redis_host="10.0.5.51:6379"
redis_password="password"
redis_database="0"
migration_file="employee-api/migration.json"
cassandra_url="cassandra://$scylla_host/$scylla_keyspace?username=$scylla_username&password=$scylla_password"

# Install Go
if ! command -v go &> /dev/null; then
    echo "Installing Go..."
    wget https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
    source ~/.profile
    go version
else
    echo "Go is already installed."
fi

# Install "migrate" tool
if ! command -v migrate &> /dev/null; then
    echo "Installing the 'migrate' tool..."
    wget https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz
    tar -xvzf migrate.linux-amd64.tar.gz
    sudo mv migrate /usr/local/bin/migrate
else
    echo "'migrate' tool is already installed."
fi

# Install "jq"
if ! command -v jq &> /dev/null; then
    echo "Installing 'jq'..."
    sudo apt update
    sudo apt install jq -y
else
    echo "'jq' is already installed."
fi



# Clone the Git repository
if [ ! -d "employee-api" ]; then
    echo "Cloning the employee-api Git repository..."
    git clone https://github.com/OT-MICROSERVICES/employee-api.git
else
    echo "The employee-api repository is already cloned."
fi



# Update config.yaml with ScyllaDB and Redis configurations

cat <<EOL > "$config_file"
scylladb:
  host: ["$scylla_host"]
  username: $scylla_username
  password: $scylla_password
  keyspace: $scylla_keyspace

redis:
  enabled: $redis_enabled
  host: $redis_host
  password: $redis_password
  database: $redis_database
EOL

# Update migration.json with the new host and database name
cat <<EOL > "$migration_file"
{
  "database": "$cassandra_url"
}
EOL

echo "Configuration files updated."

# Build the Go project
cd employee-api
go build -o employee-api

echo "Go project 'employee-api' is built."
