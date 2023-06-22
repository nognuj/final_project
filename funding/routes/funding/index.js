'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read only 인데 이게 참 쉽지가 않네 다 된 줄 알았는데 하루종일 하고 있다야' }
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
