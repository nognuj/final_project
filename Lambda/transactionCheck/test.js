// const AWS = require("aws-sdk");

// const sns = new AWS.SNS({ region: "ap-northeast-2" }); // 지역(region)은 해당 토픽이 생성된 지역으로 설정해주세요.

// const topicArn = "arn:aws:sns:ap-northeast-2:156557625960:targetAmountReached";

// const date = new Date("2023-06-21T17:49:42.390Z");
// const message = {
//   payload: {
//     date,
//     destination: "pament_attempt",
//     destination: "goal_achivement",
//   },
// };

// const params = {
//   Message: JSON.stringify(message),
//   TopicArn: topicArn,
// };

// sns.publish(params, (err, data) => {
//   if (err) {
//     console.error("Failed to publish SNS message:", err);
//   } else {
//     console.log("SNS message published successfully:", data.MessageId);
//   }
// });
const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const dynamodb = new AWS.DynamoDB.DocumentClient({ region });

(async () => {
  let date = new Date("2023-06-21T17:49:42.390Z");
  let params = {
    TableName: "paymentTransactions",
    FilterExpression: "#createdAt > :date",
    ExpressionAttributeValues: {
      ":date": `"${date.toISOString()}"`, // 쌍따옴표를 추가합니다.
    },
    ExpressionAttributeNames: {
      "#createdAt": "createdAt",
    },
  };
  let response = await dynamodb.scan(params).promise();
  const filteredItems = response.Items.filter((el) => {
    const parsedMessage = JSON.parse(el.message);
    const status = parsedMessage.status;
    if (status === 1) {
      return true;
    }
  });
  for (let i = 0; i < filteredItems.length; i++) {
    const { payload = {} } = JSON.parse(filteredItems[i].message);
    payload.paymentId = filteredItems[i].id;
    const params = {
      Message: {
        status: 3,
        payload,
      },
      TopicArn: PAYMENT_ATTEMPT_TOPIC_ARN,
    };
    await sns.publish(params).promise();
  }
})();
