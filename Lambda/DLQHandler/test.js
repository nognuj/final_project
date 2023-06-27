const axios = require("axios");
const url =
  "https://e87z0kfwe1.execute-api.ap-northeast-2.amazonaws.com/prod/broker";
const headers = {
  Auth: true,
};
const body = {
  destination: "goal_achivement",
  payload: {
    date: new Date("2023-06-27T06:31:10.203Z"),
  },
};

(async () => {
  const result = await axios.post(url, body, { headers });
  console.log(result);
})();
