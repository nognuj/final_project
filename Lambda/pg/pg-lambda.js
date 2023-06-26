const AWS = require("aws-sdk");
const { insertMessageIntoDynamoDB } = require("./src/common/awsFunction");
const region = "ap-northeast-2";
const sns = new AWS.SNS({ region });
const sqs = new AWS.SQS({ region });
require("dotenv").config();
const { PAYMENT_DLQ, ETC_DLQ, APPROVE_PAYMENT_TOPIC, FOR_MAIL } = process.env;
const failEvent = async (status, payload) => {
  const randomNum = Math.floor(Math.random() * 6);
  if (!randomNum) {
    const msg = {
      toDiscord: true,
      from: "payment",
      status,
      payload,
    };
    const sendDlqSqsParams = {
      MessageBody: JSON.stringify(msg),
      QueueUrl: PAYMENT_DLQ,
    };
    await sqs.sendMessage(sendDlqSqsParams).promise();
    return true;
  }
  return false;
};

const snsPublish = async ({ TopicArn, Message }) => {
  const approvePaymentSnsParams = {
    TopicArn,
    Message,
  };
  await sns.publish(approvePaymentSnsParams).promise();
};

exports.handler = async (event) => {
  // 모듈 오류

  for (const record of event.Records) {
    console.log(record);
    const body = JSON.parse(record.body);

    const { status, payload } = JSON.parse(body.Message);
    //기존1

    //기존2
    let sendMailSnsParams;
    if (await failEvent(status, payload)) {
      console.log("someting went wrong");
      return "someting went wrong";
    }

    if (status === 1 || status === 3) {
      // status가 1일 때 SNS 토픽 발행
      // 성공 케이스
      const approvePaymentSnsParams = {
        TopicArn: APPROVE_PAYMENT_TOPIC,
        Message: JSON.stringify(payload),
      };
      try {
        const PaymentTransaction = {
          payload,
          status,
        };
        await snsPublish(approvePaymentSnsParams);
        await insertMessageIntoDynamoDB(PaymentTransaction);
      } catch (error) {
        console.log(error);
        const msg = {
          status: "fail",
          code: 404,
        };
        const sendDlqSqsParams = {
          MessageBody: JSON.stringify(msg),
          QueueUrl: PAYMENT_DLQ,
        };
        await sqs.sendMessage(sendDlqSqsParams).promise();
        return false;
      }
    } else if (status === 2) {
      // status가 2일 때 SNS 토픽 발행 및 SQS로 메시지 전송
      // 실패 케이스(잔액 부족, 카드 회사 점검 등등..)
      const msg = {
        toDiscord: true,
        from: "payment",
        status,
        payload,
      };

      const sendDlqSqsParams = {
        MessageBody: JSON.stringify(msg),
        QueueUrl: ETC_DLQ,
      };

      await sqs.sendMessage(sendDlqSqsParams).promise();

      const PaymentTransaction = {
        payload,
        status,
      };
      await insertMessageIntoDynamoDB(PaymentTransaction);
    }
    const sendMailInfo = {
      toDiscord: false,
      from: "sendEmail",
      senderEmail: "ehddnr4870@gmail.com", // 발신자 이메일 주소
      receiverEmail: "xehddnr@naver.com",
      subject: "동욱님의 펀딩 참여.",
      body: "어쩌구 저쩌구~~~",
    };
    console.log(sendMailInfo);
    sendMailSnsParams = {
      TopicArn: FOR_MAIL,
      Message:
        status === 1
          ? JSON.stringify(sendMailInfo)
          : JSON.stringify(sendMailInfo),
      //메세지는 email이 포함된 직렬화된 객체가 되어야 합니다.
    };
    await snsPublish(sendMailSnsParams);
  }
  return true;
};
