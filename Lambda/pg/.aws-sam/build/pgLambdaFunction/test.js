const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const dynamodb = new AWS.DynamoDB.DocumentClient({ region });
const sns = new AWS.SNS({ region });
const msg = {
  status: 2,
  payload: {
    fundingId: 1,
    amount: 10000,
    paymentMethod: "credit card",
  },
}; //json 데이터를 써주시면 됩니다.
const snsPublishTopic = async (msg) => {
  // const params = {
  //   TableName: "paymentTransactions",
  //   //환경 변수로 대체
  //   Item: {
  //     id: "2",
  //     messageId: "1",
  //     message: JSON.stringify(msg),
  //   },
  // };
  // await dynamodb.put(params).promise();
  sendMailSnsParams = {
    TopicArn: "arn:aws:sns:ap-northeast-2:156557625960:payment_approval_request",
    Message: JSON.stringify(msg),
  };
  console.log(sendMailSnsParams);
  await sns.publish(sendMailSnsParams).promise();
};

const getPreviousId = async () => {
  const params = {
    TableName: "paymentTransactions",
    ScanIndexForward: false,
  };
  try {
    const result = await dynamodb.scan(params).promise();
    const sorted = result.Items.sort((a, b) => new Date(JSON.parse(b.createdAt)) - new Date(JSON.parse(a.createdAt)));
    if (result.Items.length > 0) {
      const previousId = sorted[0].id; // ID의 속성 이름에 따라 변경
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

(async () => {
  await snsPublishTopic(msg);
  //await getPreviousId();
})();
