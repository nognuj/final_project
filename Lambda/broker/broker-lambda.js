const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const sns = new AWS.SNS({ region });
require("dotenv").config();

const { PAYMENT_ATTEMPT_TOPIC_ARN, GOAL_ACHIVEMENT_TOPIC_ARN } = process.env;

const SNSArns = {
  payment_attempt: PAYMENT_ATTEMPT_TOPIC_ARN,
  goal_achivement: GOAL_ACHIVEMENT_TOPIC_ARN,
};
exports.handler = async (event, context) => {
  console.log(event);
  const auth = Boolean(event.headers["Auth"]);
  console.log(auth);
  const { body } = event;
  console.log(body);

  const { status, payload, destination } = JSON.parse(body);
  console.log("------destination-----");
  console.log(destination);
  // const auth = headers["Auth"];
  if (auth !== true) {
    console.log("haha");
    return {
      statusCode: 403,
      body: JSON.stringify({ message: "permission denied" }),
    };
  }

  const params = {
    Message: JSON.stringify({
      status,
      payload,
    }),
    TopicArn: SNSArns[destination],
  };
  console.log("----params-----");
  console.log(params);
  try {
    await sns.publish(params).promise();

    try {
      return {
        statusCode: 200,
        body: JSON.stringify({ message: "SNS message published" }),
      };
    } catch (error) {
      console.log(error);
      return error;
    }
  } catch (error) {
    return {
      statusCode: 503,
      body: JSON.stringify({
        error,
        message: "something went wrong",
      }),
    };
  }
};
