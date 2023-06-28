## Environment
<div>
<img src="https://img.shields.io/badge/aws-232F3E?style=for-the-badge&logo=aws&logoColor=white">
<img src="https://img.shields.io/badge/mysql-4479A1?style=for-the-badge&logo=mysql&logoColor=white">
<img src="https://img.shields.io/badge/javascript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black">
<img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white">
<img src="https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white">
<img src="https://img.shields.io/badge/linux-FCC624?style=for-the-badge&logo=linux&logoColor=black">
<img src="https://img.shields.io/badge/terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=#7B42BC"> 
<img src="https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=Docker&logoColor=white"/>
<img src="https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=Ubuntu&logoColor=white"/>
<img src="https://img.shields.io/badge/Visual Studio Code-007ACC?style=flat-square&logo=Visual Studio Code&logoColor=white"/>
</div>  


## **DevOps-04-Final-Team08**
**-Team: 우도현 / 이동욱 / 송가현 / 지정온 / 박성필**

# **선정 주제 : 크라우드 펀딩**

## **핵심기능 요구사항**
* 판매자가 크라우드펀딩 제품을 오픈하고 펀딩을 받는다.
* 후원자가 프로젝트에 일정 금액을 펀딩한다.
* 목표 금액이 달성되면, 해당 프로젝트는 성공으로 간주한다. 

## **인프라 요구사항**
* 사용되는 애플리케이션들은 컨테이너로 구동되어야합니다.
* 시스템 전반에 가용성, 내결함성, 확장성, 보안성이 고려된 서비스들이 포함되어야 합니다.
* 하나 이상의 컴퓨팅 유닛에 대한 CI/CD 파이프라인이 구성되어야합니다.
* 시스템 메트릭 또는 저장된 데이터에 대한 하나 이상의 시각화된 모니터링 시스템이 구축되어야합니다.

## **Architecture**
![image](https://github.com/cs-devops-bootcamp/devops-04-Final-Team8/assets/127210671/413bc647-1ad9-4545-8b4a-4345b55d856f)



## **기능 설명**
1. 결제가 완료되면 SNS를 통해 q 메시지가 전송됩니다. 결제 게이트웨이(PG) 회사와 통합된 람다 기능이 이 프로세스를 처리합니다.
2. PG사 연동 실패 시 해당 메시지는 DLQ(Dead Letter Queue)로 빠지고 DLQ 내 SNS lambda를 이용하여 재시도한다. PG사는 Lambda 함수를 통해 성공 또는 실패 응답을 제공할 수 있습니다.
3. 결제가 승인되면 Funding Update Request Lambda를 트리거합니다. 이 람다는 PG사와의 결제 연동 성공 여부에 따라 펀딩 SNS에 업데이트 됩니다.
4. Target SNS는 펀딩 과정에서 목표 달성 이벤트를 처리합니다. Transaction Check Lambda는 목표 달성 직전에 지불이 완료되었는지 확인하는 데 사용됩니다. 이러한 경우가 있을 경우 결제 SNS 승인이 취소되며, 거래내역은 참고용으로 거래 DB(DynamoDB)에 분리되어 있습니다.
5. 모든 결제는 결제 SNS에서 발생하며 나중에 참조할 수 있도록 DynamoDB에 저장됩니다. 필요한 경우 SES(Simple Email Service)를 사용할 수 있습니다.


# **API 명세**

<html>
<body>
<!--StartFragment-->

| Method | Path                                           | Function                      | Request Header                       | Request Body                                                                                           | Response Header | Response Body                                                                                                               |
| ------ | ---------------------------------------------- | ----------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------ | --------------- | --------------------------------------------------------------------------------------------------------------------------- |
| POST   | /api/funding                              | 새 프로젝트 만들기            | Authorization: Bearer [Access Token] | { "title": "제목", "description": "설명", "goalAmount": <amount>, "duration": 50,"startDate":date Type, "endDate":date Type,status: 1, fundingAmount:10000000, minAmount:10000, maxAmount:1000000 } | N/A             | { status:201, payload:"success" } |
| GET    | /api/fundings                  | 프로젝트 목록       | N/A                                  | N/A                                                                                                    | N/A             | {status:200 , payload:[{ "title": "제목", "description": "설명", "goalAmount": <amount>, "duration": 50,"startDate":date Type, "endDate":date Type,"createdAt":date Type,status: 1, fundingAmount:10000000, minAmount:10000, maxAmount:1000000 }]} | N/A             | { payload:"success" }] |
  | GET    | /api/funding/:fundingId                      | 프로젝트 세부 정보 조회       | N/A                                  | N/A                                                                                                    | N/A             | { status:200 , payload:{"title": "제목", "description": "설명", "goalAmount": <amount>, "duration": 50,"startDate":date Type, "endDate":date Type,"createdAt":date Type,status: 1, fundingAmount:10000000, minAmount:10000, maxAmount:1000000} } | N/A             | { payload:"success" } |
| PUT    | /api/funding                   | 프로젝트 세부 정보 업데이트   | Authorization: Bearer [Access Token] |  { "title": "제목", "description": "설명", "goalAmount": <amount>, "duration": 50,"startDate":date Type, "endDate":date Type,status: 1, fundingAmount:10000000, minAmount:10000, maxAmount:1000000 } | N/A             | {status:201,payload:"success"} |
| DELETE | /api/fundings/:fundingId                      | 프로젝트 삭제                 | Authorization: Bearer [Access Token] | N/A                                                                                                    | N/A             | {status:200,payload:"success"} |
| POST   | /api/payments    | 포로젝트의 새로운 결제 만들기 | Authorization: Bearer [Access Token] | { status:1,payload: {fundingId: 1,amount: 10000,paymentMethod: "credit card",},}                                             | N/A             | {status:201,payload:"success"}                 |
<!--EndFragment-->
</body>
</html>

---

## **참고레퍼런스**

https://devpress.csdn.net/cicd/62ec5d4e89d9027116a10c5e.html

[CI/CD Pipeline for Amazon ECS/FARGATE with Terraform]

https://aws.amazon.com/ko/blogs/architecture/field-notes-how-to-deploy-end-to-end-ci-cd-in-the-china-regions-using-aws-codepipeline/

[Deploy End-to-End CI/CD in the China Regions Using AWS CodePipeline]

https://dev.to/aws-builders/setting-up-aws-code-pipeline-to-automate-deployment-of-tweets-streaming-application-m7o

[Setting up AWS Code Pipeline]

https://catalog.us-east-1.prod.workshops.aws/workshops/8c9036a7-7564-434c-b558-3588754e21f5/ko-KR/03-console/05-monitoring

[Amazon CloudWatch Contanir insite]

https://catalog.us-east-1.prod.workshops.aws/workshops/8c9036a7-7564-434c-b558-3588754e21f5/ko-KR/03-console/07-autoscale/01-service

[Server autoscaling]

https://catalog.us-east-1.prod.workshops.aws/workshops/8c9036a7-7564-434c-b558-3588754e21f5/ko-KR/03-console/07-autoscale/02-cluster

[Cluster autoscaling]

## advnace
1. ECS -> EKS
2. terraform module
