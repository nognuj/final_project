## 선정 주제 : 크라우드 펀딩
---
## API 명세


<html>
<body>
<!--StartFragment-->

| Method | Path                                           | Function                      | Request Header                       | Request Body                                                                                           | Response Header | Response Body                                                                                                               |
| ------ | ---------------------------------------------- | ----------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------ | --------------- | --------------------------------------------------------------------------------------------------------------------------- |
| POST   | /api/user/sign_up                             | 새 사용자 등록                | Content-Type: application/json       | { "name": "<name>", "email": "<email>", "password": "<password>" }                                     | N/A             | { "id": "<userId>", "name": "<name>", "email": "<email>" }                                                                  |
| GET    | /api/users                                     | 사용자 정보 검색              | Authorization: Bearer [Access Token] | N/A                                                                                                    | N/A             | [{ "id": "<userId>", "name": "<name>", "email": "<email>" }]    
  | GET    | /api/user/{userId}                                  | 특정 사용자 정보 검색              | Authorization: Bearer [Access Token] | N/A                                                                                                    | N/A             | { "id": "<userId>", "name": "<name>", "email": "<email>" }    |
| PUT    | /api/user                                   | 사용자 정보 업데이트          | Authorization: Bearer [Access Token] | { "name": "<name>", "email": "<email>" }                                                               | N/A             | { "id": "<userId>", "name": "<name>", "email": "<email>" }                                                                  |
| DELETE | /api/user                                     | 사용자 삭제                   | Authorization: Bearer [Access Token] | N/A                                                                                                    | N/A             | { "id": "<userId>", "name": "<name>", "email": "<email>" }                                                                  |
| POST   | /api/funding                              | 새 프로젝트 만들기            | Authorization: Bearer [Access Token] | { "title": "<title>", "description": "<description>", "goalAmount": <amount>, "duration": <duration> } | N/A             | { "id": "<fundingId>", "title": "<title>", "description": "<description>", "goalAmount": <amount>, "duration": <duration> } |
| GET    | /api/fundings                  | 프로젝트 목록       | N/A                                  | N/A                                                                                                    | N/A             | [{ "id": "fundingId", "title": "title", "description": "description", "goalAmount": amount, "duration": duration }] |
  | GET    | /api/funding/{fundingId}                      | 프로젝트 세부 정보 조회       | N/A                                  | N/A                                                                                                    | N/A             | { "id": "<fundingId>", "title": "<title>", "description": "<description>", "goalAmount": <amount>, "duration": <duration> } |
| PUT    | /api/funding                   | 프로젝트 세부 정보 업데이트   | Authorization: Bearer [Access Token] | { "id":"fundingId","title": "<title>", "description": "<description>", "goalAmount": <amount>, "duration": <duration> } | N/A             | { "id": "<fundingId>", "title": "<title>", "description": "<description>", "goalAmount": <amount>, "duration": <duration> } |
| DELETE | /api/fundings/{fundingId}                      | 프로젝트 삭제                 | Authorization: Bearer [Access Token] | N/A                                                                                                    | N/A             | { "id": "<fundingId>", "title": "<title>", "description": "<description>", "goalAmount": <amount>, "duration": <duration> } |
| POST   | /api/payments    | 포로젝트의 새로운 결제 만들기 | Authorization: Bearer [Access Token] | { fundingId:"fundingId", "amount": "amount", "paymentMethod": "paymentMethod" }                                             | N/A             | { "id": "<fundingId>", "fundingId": "<fundingId>", "amount": <amount>, "paymentMethod": "<paymentMethod>" }                 |
| GET    | /api/payments/{paymentsId}             | 프로젝트의 결제 세부정보 조회 | Authorization: Bearer [Access Token] | N/A                                                                                                    | N/A             | [{ "id": "<fundingId>", "fundingId": "<fundingId>", "amount": <amount>, "paymentMethod": "<paymentMethod>" }]               |
| PUT    | /api/payments/{paymentsId} | 프로젝트의 결제 정보 업데이트 | Authorization: Bearer [Access Token] | { "amount": <amount>, "paymentMethod": "<paymentMethod>" }                                             | N/A             | { "id": "<fundingId>", "fundingId": "<fundingId>", "amount": <amount>, "paymentMethod": "<paymentMethod>" }                 |
| POST | /api/payments/cancle | 프로젝트의 결제 취소          | Authorization: Bearer [Access Token] |{"fundingId":"fundingId"}                                                                                                   | N/A             | { "id": "<fundingId>", "fundingId": "<fundingId>", "amount": <amount>, "paymentMethod": "<paymentMethod>" }                 |

<!--EndFragment-->
</body>
</html>

## Swaagger 링크(advanced)
[링크 여기에 넣을 거에요](https://app.swaggerhub.com/apis/seay0/shopping_mall/1.0.0#/)  

---

