#퍼블릭 보안 그룹 생성
resource "aws_security_group" "pub_sg" {
    vpc_id = aws_vpc.lastvpc.id
    name = "sprint-pub-sg"
    description = "project-pub-sg"

    tags = {
        Name = "project-pub-sg"
    }
}

#퍼블릭 보안 그룹 규칙
resource "aws_security_group_rule" "pubsghttp" {
    type = "ingress"
    from_port = 80
    to_port=80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.pub_sg.id
    lifecycle{
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "pubsghttp2" {
    type = "ingress"
    from_port = 8080
    to_port=8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.pub_sg.id
    lifecycle{
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "pub_sg_ssh" {
    type = "ingress"
    from_port = 22
    to_port= 22
    protocol = "TCP"
    cidr_blocks=["0.0.0.0/0"]
    security_group_id = aws_security_group.pub_sg.id
    lifecycle{
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "pub_sg_all" {
    type = "egress"
    from_port = 0
    to_port= 0
    protocol = "-1"
    cidr_blocks=["0.0.0.0/0"]
    security_group_id = aws_security_group.pub_sg.id
    lifecycle{
        create_before_destroy = true
    }
}