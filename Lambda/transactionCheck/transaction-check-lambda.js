const AWS = require("aws-sdk");
const region = "ap-northeast-2";

const dynamodb = new AWS.DynamoDB.DocumentClient({ region });
const sns = new AWS.SNS({ region });
require("dotenv").config();

exports.handler = async (event) => {
  const { PAYMENT_ATTEMPT_TOPIC_ARN } = process.env;
  // Parse date from SQS message
  console.log("-------event------");
  console.log(event);
  const body = JSON.parse(event.Records[0].body);
  console.log("-------sqsMessage------");
  console.log(body);
  const { payload } = JSON.parse(body.Message);
  console.log("-------payload------");
  console.log(payload);
  const date = new Date(payload.date);
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
};
