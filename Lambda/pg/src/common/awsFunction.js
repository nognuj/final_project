const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const dynamodb = new AWS.DynamoDB.DocumentClient({ region });
require("dotenv").config();
const { DYNAMO_DB_TABLE_NAME } = process.env;
const getPreviousId = async () => {
  const params = {
    TableName: DYNAMO_DB_TABLE_NAME,
    ScanIndexForward: false,
  };
  try {
    const result = await dynamodb.scan(params).promise();
    const sorted = result.Items.sort(
      (a, b) =>
        new Date(JSON.parse(b.createdAt)) - new Date(JSON.parse(a.createdAt))
    );
    if (result.Items.length > 0) {
      const previousId = sorted[0].id; // ID의 속성 이름에 따라 변경
      console.log("Previous ID:", previousId);
      return previousId;
    } else {
      console.log("No previous ID found.");
      return 0;
    }
  } catch (error) {
    console.error("Error retrieving previous ID:", error);
    throw error;
  }
};

const generateId = async () => {
  const previousId = Number(await getPreviousId());
  console.log("previousId", previousId);
  return String(previousId + 1);
};

const insertMessageIntoDynamoDB = async (msg) => {
  const id = await generateId();
  console.log("---- id :", id, "-----");
  const now = new Date();
  const params = {
    TableName: DYNAMO_DB_TABLE_NAME,
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
