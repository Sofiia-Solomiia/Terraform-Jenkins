resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  key_name               = aws_key_pair.deployer.key_name
  user_data              = file("userdata.tpl")

  tags = {
    Name = "${var.project_name}-web-server"
  }
}
