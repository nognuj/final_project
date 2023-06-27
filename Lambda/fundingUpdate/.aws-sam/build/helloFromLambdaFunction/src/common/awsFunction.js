const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const dynamodb = new AWS.DynamoDB.DocumentClient({ region });

const getPreviousId = async () => {
  const params = {
    TableName: "paymentTransactions",
    ProjectionExpression: "#id",
    ExpressionAttributeNames: {
      "#id": "id",
    },
    ScanIndexForward: false,
    Limit: 1,
  };
  try {
    const result = await dynamodb.scan(params).promise();
    if (result.Items.length > 0) {
      const previousId = result.Items[0].id; // ID의 속성 이름에 따라 변경
      console.log("Previous ID:", previousId);
      return previousId;
    } else {
      console.log("No previous ID found.");
      return null;
    }
  } catch (error) {
    console.error("Error retrieving previous ID:", error);
    throw error;
  }
};

const generateId = async () => {
  const previousId = Number(await getPreviousId());
  return String(previousId + 1);
};

const insertMessageIntoDynamoDB = async (msg) => {
  const id = await generateId();
  console.log("---- id :", id, "-----");
  const now = new Date();
  const params = {
    TableName: "paymentTransactions",
    //환경 변수로 대체
    Item: {
      id,
      message: JSON.stringify(msg),
      createdAt: JSON.stringify(now),
    },
  };
  console.log(params);
  await dynamodb.put(params).promise();
};

module.exports = {
  getPreviousId,
  generateId,
  insertMessageIntoDynamoDB,
};
