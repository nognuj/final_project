'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async function (request, reply) {
    return { root: '/funding read only ci/cd 이게 맞는 건지 모르겠다 도대체 이렇게 두번 !! 해야 되는 걸까?!' }
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
