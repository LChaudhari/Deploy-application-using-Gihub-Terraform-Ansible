#Launch ec2
resource "aws_instance" "ec2instance_public" {
    ami = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
    subnet_id = aws_subnet.Npublicsubnets.id
    associate_public_ip_address = true
    key_name = "postgres"
    tags =  {
      "Name" = "Nginx"
    }
    depends_on = [
      aws_security_group.nginx_sg
    ]
}

#Create vpc
 resource "aws_vpc" "Nginx_vpc" {                
   cidr_block       = "10.0.0.0/16"     
   instance_tenancy = "default"
 }

#Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "Nginx_IGW" {    
    vpc_id =  aws_vpc.Nginx_vpc.id              
} 

resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  description = "Allow http inbound traffic and outbound traffic"
  vpc_id = aws_vpc.Nginx_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

 # Create a Public Subnets.
 resource "aws_subnet" "Npublicsubnets" {    
   vpc_id =  aws_vpc.Nginx_vpc.id
   cidr_block = "10.0.1.0/24"       
 }

 # Create a Private Subnet                   
 resource "aws_subnet" "Nprivatesubnets" {
   vpc_id =  aws_vpc.Nginx_vpc.id
   cidr_block = "10.0.2.0/24"
   }       

# Route table for Public Subnet's
resource "aws_route_table" "NgPublicRT" {    
    vpc_id =  aws_vpc.Nginx_vpc.id
         route {
    cidr_block = "0.0.0.0/0"               
    gateway_id = aws_internet_gateway.Nginx_IGW.id
     }
}
resource "aws_route_table_association" "Ngpublicid" {
  subnet_id = aws_subnet.Npublicsubnets.id
  route_table_id = aws_route_table.NgPublicRT.id
}

# Route table for Private Subnet's
# resource "aws_route_table" "NgPrivateRT" {    
#   vpc_id = aws_vpc.Nginx_vpc.id
#    route {
#    cidr_block = "0.0.0.0/0"             
#    nat_gateway_id = aws_nat_gateway.Ng_NATgw.id
#    }
# } 
# resource "aws_route_table_association" "Ngprivateid" {
#   subnet_id = aws_subnet.Nprivatesubnets.id
#   route_table_id = aws_route_table.NgPrivateRT.id
# }  

# resource "aws_eip" "Ng_nateIP" {
#   vpc              = true
# }
 
#Creating the NAT Gateway using subnet_id and allocation_id
# resource "aws_nat_gateway" "Ng_NATgw" {
#   allocation_id = aws_eip.Ng_nateIP.id
#   subnet_id = aws_subnet.Npublicsubnets.id
# }
 
