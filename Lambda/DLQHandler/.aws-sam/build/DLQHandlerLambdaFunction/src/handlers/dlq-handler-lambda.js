const AWS = require("aws-sdk");
const axios = require("axios");

exports.handler = async (event) => {
  const sqs = new AWS.SQS();
  const queueUrls = {
    sendEmail: "https://sqs.ap-northeast-2.amazonaws.com/156557625960/sendEmail",
    payment: "https://sqs.ap-northeast-2.amazonaws.com/156557625960/payment_queue",
    //환경 변수로 대체되어야함.
  };
  const discordWebhookUrl = "https://discord.com/api/webhooks/1121115147944083507/_vhVnWFlKlYjFy5gu2K07uR0GHv92qEy7qtBRvqXiJyM_3DS9O3GOPs5JtF5nj9JJEJj";

  try {
    const retryMessages = event.Records[0];
    console.log(retryMessages);
    const { body, attributes } = retryMessages;
    const parsedBbody = JSON.parse(body);
    // 요청 횟수가 3회 초과 혹은 body에 바로 디스코드로 보내는 값이 있으면
    // 디스코드 웹훅을통해 메시지를 보낸다
    //그게 아니면 body값에서 어떤 값에서 왔는지 체크 후 해당 queue로 돌려보낸다.
    if (Number(attributes.ApproximateReceiveCount) > 3 || parsedBbody.toDiscord) {
      await axios.post(discordWebhookUrl, {
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
