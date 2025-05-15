#cloud-config
package_update: true
bootcmd:
# Configure ECS Agent
  - echo "## Configuring ECS Agent"
  - mkdir -p /etc/ecs
  - echo 'ECS_CLUSTER=${cluster}' >> /etc/ecs/ecs.config
  - echo 'ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE=true' >> /etc/ecs/ecs.config
  - echo 'ECS_LOGLEVEL=info' >> /etc/ecs/ecs.config
  - echo 'ECS_CONTAINER_STOP_TIMEOUT=30s' >> /etc/ecs/ecs.config
  - echo 'ECS_CHECKPOINT=true' >> /etc/ecs/ecs.config
  - echo 'ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=5m' >> /etc/ecs/ecs.config
  - echo 'ECS_RESERVED_MEMORY=160' >> /etc/ecs/ecs.config
  - echo 'ECS_IMAGE_PULL_BEHAVIOR=default' >> /etc/ecs/ecs.config
runcmd:
  # Install AWS CLI
  - yum -y remove awscli
  - curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
  - unzip awscliv2.zip
  - ./aws/install
  - rm -f awscliv2.zip
  - ln -s /usr/local/bin/aws /usr/bin/aws
  # Install New Relic Infrastructure Agent
  - docker run --detach --name ${cluster} --cap-add=SYS_PTRACE --privileged --cgroupns=host --pid=host --volume "/:/host:ro" --volume "/var/run/docker.sock:/var/run/docker.sock" --volume "newrelic-infra:/etc/newrelic-infra" --env NRIA_LICENSE_KEY=822ab00b79d15dda237db4eae68d5263FFFFNRAL newrelic/infrastructure:latest
  # Install Xray
  - |
    arch=$( [ $(uname -m) == "aarch64" ] && echo "arm64-" || echo "" )
    curl "https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-$${arch}3.x.rpm" -o /home/ec2-user/xray.rpm
  - yum install -y /home/ec2-user/xray.rpm
  - rm -f /home/ec2-user/xray.rpm
  - iptables -A INPUT -p udp -s 0/0 -d 172.17.42.1 --sport 0:65535 --dport 2000 -m state --state NEW,ESTABLISHED -j ACCEPT
  - iptables-save
  - sed -i "s/Type=.*/Type=simple/g" /etc/systemd/system/xray.service
  - sed -i "s/ExecStart=.*/ExecStart=\/usr\/bin\/xray -f \/var\/log\/xray\/xray.log -b \"0.0.0.0:2000\" -t \"0.0.0.0:2000\" -l dev/g" /etc/systemd/system/xray.service
  - systemctl daemon-reload
  - systemctl enable xray
  - systemctl stop xray
  - systemctl start xray
  - systemctl status xray

  # Install Nginx for health check
  - yum -y install nginx
  - systemctl start nginx
  - systemctl enable nginx  
  
  # Install and configure CloudWatch agent for disk usage
  - yum install -y amazon-cloudwatch-agent
  - mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
  - |
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
    {
      "agent": {
        "run_as_user": "root"
      },
      "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
          "disk": {
            "resources": [
              "/"
            ],
            "measurement": [
              {"name": "disk_used_percent", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60
          },
          "mem": {
            "measurement": [
              {"name": "mem_used_percent", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60
          }
        },
        "append_dimensions": {
          "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
          "InstanceId": "$${aws:InstanceId}"
        },
        "aggregation_dimensions":
              [["AutoScalingGroupName"], ["AutoScalingGroupName", "InstanceId"]]
      }
    }
    EOF


  # Start and enable CloudWatch agent
  - /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
  - systemctl start amazon-cloudwatch-agent
  - systemctl enable amazon-cloudwatch-agent

  # Clean up
  - yum clean all
  # Add limit to journalctl log size
  - sed -i 's/#SystemMaxUse=/SystemMaxUse=100M/g' /etc/systemd/journald.conf
