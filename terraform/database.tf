data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "${var.cluster_name}-db-creds"
}


locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.db_creds.secret_string
  )

  # MakeDatabaseNameCamelCased
  db_name = replace(title(replace("${var.cluster_name}", "-", " ")), " ", "")
}


resource "aws_db_subnet_group" "db" {
  name = var.cluster_name
  subnet_ids = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

  tags = {
    Name = "${var.cluster_name}"
  }
}


resource "aws_security_group" "database" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Incoming access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_private_subnet1_cidr,
      var.vpc_private_subnet2_cidr
    ]
  }

  tags = {
    Name = "${var.cluster_name}-database"
  }
}


resource "aws_db_instance" "db" {
  identifier           = var.cluster_name
  allocated_storage    = var.db_storage_size_in_gb
  engine               = var.db_engine
  instance_class       = var.db_instance_class
  name                 = local.db_name
  db_subnet_group_name = aws_db_subnet_group.db.name
  username             = local.db_creds.db_user
  password             = local.db_creds.db_pass
  multi_az             = var.db_multi_az
  skip_final_snapshot  = var.db_skip_final_snapshot
  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  depends_on = [aws_db_subnet_group.db]
}
