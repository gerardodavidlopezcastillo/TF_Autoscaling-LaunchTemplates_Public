# Autoscaling Group Resource
resource "aws_autoscaling_group" "my_asg" {
  name_prefix = "myasg-"
  desired_capacity = 2
  max_size = 10
  min_size = 2
  vpc_zone_identifier = module.vpc.private_subnets
  
  # Change-1: ALB Module upgraded to 9.4.0 
  #target_group_arns = module.alb.target_group_arns 
  target_group_arns = [module.alb.target_groups["mytg1"].arn] # UPDATED 
  
  health_check_type = "EC2"
  #health_check_grace_period = 300 # default is 300 seconds
  launch_template {
    id = aws_launch_template.my_launch_template.id 
    version = aws_launch_template.my_launch_template.latest_version
  }
  # Instance Refresh
  instance_refresh {
    strategy = "Rolling"
    preferences {
      # instance_warmup = 300 # Default behavior is to use the Auto Scaling Groups health check grace period value
      min_healthy_percentage = 50            
    }
    triggers = [ "desired_capacity" ] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger   
  }
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
}
