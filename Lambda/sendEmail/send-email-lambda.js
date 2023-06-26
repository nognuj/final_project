const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const ses = new AWS.SES({ region });

exports.handler = async (event, context) => {
  const body = JSON.parse(event.Records[0].body);
  const message = JSON.parse(body.Message);

  try {
    // SQS 메시지 파싱

    // SES로 메시지 전송
    const sesParams = {
      Source: message.senderEmail, // 발신자 이메일 주소
      Destination: {
        ToAddresses: [message.receiverEmail], // 수신자 이메일 주소
      },
      Message: {
        Subject: {
          Data: message.subject, // 이메일 제목
        },
        Body: {
          Text: {
            Data: message.body, // 이메일 본문
          },
        },
      },
    };
    await ses.sendEmail(sesParams).promise();

    console.log("메시지 전송 완료");
    return {
      statusCode: 200,
      body: "Success",
    };
  } catch (error) {
    console.error("에러:", error);
    return {
      statusCode: 500,
      body: "Error",
    };
  }
};
