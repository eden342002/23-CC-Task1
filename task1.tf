provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "smart2" {
  ami             = "ami-0cff7528ff583bf9a"
  instance_type   = "t2.micro"
  key_name        = "Smart-Keypair1"
  security_groups = ["launch-wizard-1"]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/eden3/Downloads/Smart-Keypair1.pem")
    host        = aws_instance.smart2.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "smart"
  }

}


resource "aws_ebs_volume" "esb1" {
  availability_zone = aws_instance.smart2.availability_zone
  size              = 1
  tags = {
    Name = "smart1"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.esb1.id
  instance_id  = aws_instance.smart2.id
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.smart2.public_ip
}


resource "null_resource" "nulllocal2" {
  provisioner "local-exec" {
    command = "echo  ${aws_instance.smart2.public_ip} > publicip.txt"
  }
}



resource "null_resource" "nullremote3" {

  depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/eden3/Downloads/Smart-Keypair1.pem")
    host        = aws_instance.smart2.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/eden342002/23-CC-Task1/blob/master/20220417_095651.jpg /var/www/html/"
    ]
  }
}

resource "null_resource" "nulllocal1" {


  depends_on = [
    null_resource.nullremote3,
  ]

  provisioner "local-exec" {
    command = "start chrome  ${aws_instance.smart2.public_ip}"
  }
}
