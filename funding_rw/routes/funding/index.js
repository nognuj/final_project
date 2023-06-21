'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read write version3' }
  })

  fastify.post('/', async function (request, reply) {


    const requestBody = request.body;
    // console.log(requestBody);

    // JSON.parse(): JSON 문자열을 JavaScript 객체로 변환
    let parseBody = JSON.parse(requestBody);
    // console.log(parseBody);
    
    
    let ret = parseBody.body +' success';
  
    // Set the response status code
    reply.code(201);
    // Send the request body as the response
    return { ret: ret};
  })

}
