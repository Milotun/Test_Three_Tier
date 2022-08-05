# to install postgresclient
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install postgresql10
psql --version