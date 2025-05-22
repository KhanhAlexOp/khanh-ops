data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "rds-vpc" }
}

resource "aws_subnet" "main" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "rds-subnet-${count.index}" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "rds-igw" }
}

resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.main[*].id
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "db" {
  length  = 16
  special = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~"
}

resource "aws_secretsmanager_secret" "db" {
  name = "rds-postgres-credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "postgresadmin"
    password = random_password.db.result
  })
}

resource "aws_db_instance" "postgres" {
  identifier              = "demo-postgres"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15.11"
  instance_class          = "db.t3.micro"
  db_name                 = "appdb"
  username                = jsondecode(aws_secretsmanager_secret_version.db.secret_string)["username"]
  password                = jsondecode(aws_secretsmanager_secret_version.db.secret_string)["password"]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
  multi_az                = false
  backup_retention_period = 0
  deletion_protection     = false
  apply_immediately       = true

}