const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const dynamodb = new AWS.DynamoDB.DocumentClient({ region });

exports.handler = async (event) => {
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
  console.log("-------date------");
  console.log(date.toISOString());
  const params = {
    TableName: "paymentTransactions",
    FilterExpression: "#createdAt > :date",
    ExpressionAttributeValues: {
      ":date": `"${date.toISOString()}"`,
    },
    ExpressionAttributeNames: {
      "#createdAt": "createdAt",
    },
  };

  try {
    const data = await dynamodb.scan(params).promise();
    console.log("-------data------");
    console.log(data);
    const { message } = data.Items;
    console.log("-------message------");
    console.log(message);
    return data.Items;
  } catch (err) {
    console.error(err);
    throw err;
  }
};
