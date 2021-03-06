


resource "aws_instance" "testing_code_host" {
  # first amazon linux on the console:  ami-e251209a
  ami = "ami-e251209a"
  instance_type = "t1.micro"
  subnet_id = "${module.subnet_private_west_2a.created_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.ssh_only_mybigfatcompany.id}", "${aws_security_group.ping_only_mybigfatcompany.id}", "${aws_security_group.ping_only_qa_vpc.id}"]
  #vpc_security_group_ids = ["${aws_security_group.ssh_only_mybigfatcompany.id}", "${aws_security_group.ping_only_qa_vpc.id}"]
  availability_zone = "us-west-2a"
  key_name = "${aws_key_pair.key_bastion.key_name}"
  private_ip = "1.1.1.51"   #subnet: private: west: 2a: 32-63

  # copy a local file on the ec2 host
  provisioner "file" {
    source      = "./foobar_script.sh"
    destination = "~/foobar_script.sh"
    connection {
            type = "ssh"
            user = "ec2-user"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
  }

  tags {
  Name = "delete this"
  }

  #user_data = "apt-get update -y"
  #user_data = "file://home/ec2-user/foobar_script.sh"
  #user_data = "chmod 744 home/ec2-user/foobar_script.sh; sudo ./foobar_script.sh"
  #user_data = "chmod 744 /home/ec2-user/foobar_script.sh"


  provisioner "remote-exec" {
    connection {
            type = "ssh"
            user = "ec2-user"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    
      inline = [<<EOF

      sudo echo hi >> /tmp/hi
      sudo chmod 744 /home/ec2-user/foobar_script.sh
      sudo /home/ec2-user/foobar_script.sh

  EOF
  ]
}


}


output "private_ip_of_codetesting_host" {
  value = ["${aws_instance.testing_code_host.private_ip}"]
}

