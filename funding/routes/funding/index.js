'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read only ci/cd 잘 되고 있니? 안되고 있는 거 같은 한 커밋 늦게 올라와 이게 왜 이렇게 되는 건지 모르겠네?!?!?!?!?!?!?!?!?!??' }
  })

  fastify.get('/get', async function (request, reply) {

    // db connection
    const connection = await fastify.mysql.getConnection()

    // 일단 추출
    const [id, name, email] = await connection.query(
      `SELECT * FROM test.test01`
    )
    connection.release()
  
    // Set the response status code
    reply.code(200);
    // Send the request body as the response
    return { port: 'funding', ret: id};
  })
}
