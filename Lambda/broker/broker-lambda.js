const AWS = require("aws-sdk");
const region = "ap-northeast-2";
const sns = new AWS.SNS({ region });
require("dotenv").config();

const { PAYMENT_APPROVAL_REQUEST_SNS_ARN } = process.env;

exports.handler = async (event, context) => {
  // console.log(event);
  // const auth = Boolean(event.headers["Auth"]);
  // console.log(auth);
  const { body } = event;
  console.log(body);
  const { headers, body: Message } = body;
  console.log("----headers---");
  console.log(headers);
  console.log("-----Message----");
  console.log(Message);
  const auth = headers["auth"];
  if (auth !== true) {
    console.log("haha");
    return {
      statusCode: 403,
      body: JSON.stringify({ message: "permission denied" }),
    };
  }
  console.log("--------1--------------");
  const params = {
    Message,
    TopicArn: PAYMENT_APPROVAL_REQUEST_SNS_ARN,
  };
  console.log("--------2--------------");
  try {
    console.log("--------3--------------");
    await sns.publish(params).promise();
    console.log("--------4--------------");
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
