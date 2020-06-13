provider "aws" {
  region = "ap-south-1"
  profile = "myprofile1"
}


resource "aws_instance" "test" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "mykey1"
  security_groups = [ "launch-wizard-2" ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/LENOVO/Downloads/mykey1.pem")
    host     = aws_instance.test.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "hybrid1os"
  }

}


resource "aws_ebs_volume" "ebs1" {
  availability_zone = aws_instance.test.availability_zone
  size              = 1
  tags = {
    Name = "hybrid1ebs"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.esb1.id}"
  instance_id = "${aws_instance.test.id}"
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.test.public_ip
}


resource "null_resource" "null1"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.test.public_ip} > publicip.txt"
  	}
}



resource "null_resource" "null2"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/LENOVO/Downloads/mykey1.pem")
    host     = aws_instance.test.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Varuni17/Hybrid_Cloud.git  /var/www/html"    
    ]
  }
}



resource "null_resource" "null3"  {


depends_on = [
    null_resource.null2,
  ]

	provisioner "local-exec" {
	    command = "start chrome  ${aws_instance.test.public_ip}"
  	}
}
