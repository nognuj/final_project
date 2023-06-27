const axios = require("axios");
const { insertMessageIntoDynamoDB } = require("../common/awsFunction");

exports.fundingUpdateLambdaHandler = async (event) => {
  try {
    // event 객체에 Records 속성이 없거나 Records 배열이 비어있을 경우 예외 처리
    if (!event.Records || event.Records.length === 0) {
      throw new Error("Invalid event. No records found.");
    }
    console.log("-------1---------");

    for (const record of event.Records) {
      // SQS 메시지의 body 파싱
      const body = JSON.parse(record.body);
      const { payload } = JSON.parse(body.Message);
      // funding update에 필요한 객체가 들어있어야 함.
      console.log("done");
      // axios.put 호출을 비동기로 처리하고 완료될 때까지 대기
      //await axios.put(`${alb_url}/api/funding`, payload);
    }

    return true;
  } catch (error) {
    // axios 호출 중에 발생하는 예외나 오류 처리
    console.error("Error occurred during funding update:", error);
    return false;
  }
};
