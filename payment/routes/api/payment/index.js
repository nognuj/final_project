'use strict'
const axios = require('axios');

module.exports = async function (fastify, opts) {

// POST -> /api/payment
  fastify.post('/', async function (request, reply) {
    const API_GATEWAY_URL = "https://e87z0kfwe1.execute-api.ap-northeast-2.amazonaws.com/prod/broker";
    
    try{
      const {fundingId, amount, paymentMethod, cardNum, address} = request.body;
     
      const headers = {
        Auth: true,
      };
      const body = {
        status: 1,
        destination: "payment_attempt",
        payload: {
          fundingId: fundingId,
          cardNum: cardNum,
          amount: amount,
          paymentMethod: paymentMethod,
          address: address,
        },
      };

      const resert = await axios.post(API_GATEWAY_URL, body, { headers });
      console.log(resert);

      reply.code(201).send({ message: 'Payment created successfully' });

    } catch (error) {
      console.error('Error:', error);
      reply.code(500).send({ error: 'Internal server error' });
    }
  })
}
   
//수정1
