const axios = require("axios");
const url =
  "https://e87z0kfwe1.execute-api.ap-northeast-2.amazonaws.com/prod/broker";
const headers = {
  Auth: true,
};
//goal_achivement
//payment_attempt
const body = {
  destination: "goal_achivement",
  payload: {
    date: new Date("2023-06-27T07:38:57.563Z"),
  },
};

// const body = {
//   status: 2,
//   destination: "payment_attempt",
//   payload: {
//     fundingId: 1,
//     cardNum: "1231535253",
//     amount: 100000,
//     paymentMethod: "credit card",
//     address: "ehddnr4870@gmail.com",
//   },
// };
(async () => {
  const result = await axios.post(url, body, { headers });
  console.log(result);
})();
