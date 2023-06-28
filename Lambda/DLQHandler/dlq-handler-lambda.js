const AWS = require("aws-sdk");
const axios = require("axios");
require("dotenv").config();
exports.handler = async (event) => {
  const sqs = new AWS.SQS();
  const { SEND_EMAIL_QUEUE_URL, PAYMENT_QUEUE_URL, DISCORD_WEB_HOOK_URL } =
    process.env;
  const queueUrls = {
    sendEmail: SEND_EMAIL_QUEUE_URL,
    payment: PAYMENT_QUEUE_URL,
    //환경 변수로 대체되어야함.
  };

  try {
    const retryMessages = event.Records[0];
    console.log(retryMessages);
    const { body, attributes } = retryMessages;
    const parsedBbody = JSON.parse(body);
    // 요청 횟수가 3회 초과 혹은 body에 바로 디스코드로 보내는 값이 있으면
    // 디스코드 웹훅을통해 메시지를 보낸다
    //그게 아니면 body값에서 어떤 값에서 왔는지 체크 후 해당 queue로 돌려보낸다.
    if (
      Number(attributes.ApproximateReceiveCount) > 3 ||
      parsedBbody.toDiscord
    ) {
      await axios.post(DISCORD_WEB_HOOK_URL, {
        content: JSON.stringify(retryMessages), // replace with the message you want to send
      });
    } else {
      console.log(queueUrls[parsedBbody.from]);
      const retryParams = {
        QueueUrl: queueUrls[parsedBbody.from],
        MessageBody: JSON.stringify(parsedBbody),
      };

      await sqs.sendMessage(retryParams).promise();
    }
    return {
      statusCode: 200,
      body: "Success",
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: "Error",
    };
  }
};
