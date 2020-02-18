#variables declaration
variable testv {
    default = "pro"
}

variable "access_key" {}

variable "secret_key" {}

variable "awsregion" {

    default= "us-east-1"
    #to give value for region from cmd type the following code
    # $ terraform plan -var "awsregion = us-west-1"
}
variable "awsamis" {
    "us-east-1" = "ami-2132sa3"
    "us-west-1" = "ami-b361c72"
    "ap-south-1" = "ami-78asd7d"
  
}

#following code to be executed in cmd to set access and secret key
# $ export TF_VAR_access_key="your access key"
# $ export TF_VAR_secret_key="your secret key"



#provider
provider "aws"
{
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region= "${var.awsregion}"
}


#resource

resource "aws_instance" "resource1"
{
    ami= "${lookup(var.awsamis,var.awsregion)}"
    instance_type="t2.micro"
    security_group_id="${aws_security_group.awssg.id}"
    count = "${var.testv== "dev"? 1:2}"
    key_pair = "${aws_key_pair.keypair.key_name}"
    #count will create the number of resource according to the number assigned to it 
    provisioner "file"
    {
        source = "/user/lab1/filename"
        destination= "/etc/config"
    }
    connection
    {

     #type following command in cmd to create public and private key 
        # $ ssh-keygen -t rsh -b 4096 -f awskey
        # where -t for encryption algorithm , -b is file size , -f states file name 
      
        user= "abc"
        private_key="/user/lab1/awskey"
        public_key="/user/lab1/awskey.pub"
    }
}



resource "aws_key_pair" "keypair"
{
    key_name = "bootstarp"
        public_key = "${file("\path\awskey.pub")}"
}

output "resourceip"
{
    value="${aws_instance.resource1.public_ip}"
}

#network_secutity_group

resource "aws_security_group" "awssg" {
    name= "security group"
    ingress
    {
        from_port = 0
        to_port=0
        protocol= "tcp"
        cider = ["0.0.0.0/0"]
    }
    egress
    {
        from_port=0
        to_port=0
        protocol="-1"
        cider= ["0.0.0.0/0"]
        
    }
  
}
